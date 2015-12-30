<?php namespace App;

use GuzzleHttp\Client;
use GuzzleHttp\Exception\ClientException;

class AmazonConnector {

  /**
   * Amazon Browse Nodes for the different appliance categories
   */
  public static $BrowseNodes = [
    'dryers' => 13397481,
    'washers' => 13397491,
    'dishwashers' => 3741281,
    'freezers' => 3741331,
    'refrigerators' => 3741361
  ];

  /**
   * Category titles
   */
  public static $Categories = [
        'dryers' => 'Clothes Dryers',
        'washers' => 'Clothes Washers',
        'dishwashers' => 'Dishwashers',
        'freezers' => 'Freezers',
        'refrigerators' => 'Refrigerators'
  ];

  /**
   * Energy Star endpoints for each category dataset
   */
  public static $Endpoints = [
        'dryers' => 'https://data.energystar.gov/resource/t9u7-4d2j.json',
        'washers' => 'https://data.energystar.gov/resource/bghd-e2wd.json',
        'dishwashers' => 'https://data.energystar.gov/resource/58b3-559d.json',
        'freezers' => 'https://data.energystar.gov/resource/8t9c-g3tn.json',
        'refrigerators' => 'https://data.energystar.gov/resource/p5st-her9.json'
  ];

  /**
   * Energy usage field for each category
   */
  public static $EnergyFields = [
        'dryers' => 'estimated_annual_energy_use_kwh_yr',
        'washers' => 'annual_energy_use_kwh_year',
        'dishwashers' => 'annual_energy_use_kwh_year',
        'freezers' => 'annual_energy_use_kwh_yr',
        'refrigerators' => 'annual_energy_use_kwh_yr'
  ];

  /**
   * Return cached products from specified category
   *
   * @param  string
   * 
   * @return Array
   */
  public function getCachedItems($category = 'washers') {
    $items = \Cache::remember($category, 60, function() use ($category) {
      return $this->getItems($category);
    });
    return $items;
  }

  /**
   * Return products from specified category
   *
   * @param  string
   * 
   * @return Array
   */
  public function getItems($category = 'washers') {
    $items = [];

    // Retrieve a max of 10 pages
    for ($i = 1; $i <= 10; $i++) {
      foreach($this->makeRequest($category, $i)->xml()->Items->Item AS $item) {
        try {
          $items[] = $this->getItem($item);
        }
        catch(\Exception $e) {
          dd($e->getMessage(), json_decode(json_encode($item)));
        }
      }

      // Wait between api calls to respect Amazon rate limit
      sleep(2);
    }

    // Add ENERGY STAR usage data from ENERGY STAR API
    $items = $this->addEnergyStarData($category, $items);

    return collect($items);
  }

  /**
   * Makes REST Request to Amazon
   *
   * @param  string
   * @param  string 
   * 
   * @return GuzzleHttp\Response
   */
  public function makeRequest($category, $page) {
    $client = new Client();
    $response = $client->get($this->signRequest($category, $page));
    return $response;
  }

  /**
   * Format API request url
   *
   * @param  String
   * @param  String
   * 
   * @return String
   */
  public function signRequest($category, $page) {

    // Your AWS Access Key ID, as taken from the AWS Your Account page
    $aws_access_key_id = env('AWS_ACCESS_KEY');

    // Your AWS Secret Key corresponding to the above ID, as taken from the AWS Your Account page
    $aws_secret_key = env('AWS_SECRET_ACCESS_KEY');

    // The region you are interested in
    $endpoint = "webservices.amazon.com";

    $uri = "/onca/xml";

    $params = array(
        "Service" => "AWSECommerceService",
        "Operation" => "ItemSearch",
        "AWSAccessKeyId" => $aws_access_key_id,
        "AssociateTag" => env('AWS_ASSOCIATE_TAG'),
        "SearchIndex" => "Appliances",
        "Keywords" => "Energy Star",
        "ResponseGroup" => "Images,ItemAttributes,Reviews,SalesRank,OfferSummary,Offers",
        "ItemPage" => $page,
        "Sort" => "pmrank",
        "BrowseNode" => static::$BrowseNodes[$category],
        "Timestamp" => gmdate('Y-m-d\TH:i:s\Z')
    );

    // Set current timestamp if not set
    if (!isset($params["Timestamp"])) {
        $params["Timestamp"] = gmdate('Y-m-d\TH:i:s\Z');
    }

    // Sort the parameters by key
    ksort($params);

    $pairs = array();

    foreach ($params as $key => $value) {
        array_push($pairs, rawurlencode($key)."=".rawurlencode($value));
    }

    // Generate the canonical query
    $canonical_query_string = join("&", $pairs);

    // Generate the string to be signed
    $string_to_sign = "GET\n".$endpoint."\n".$uri."\n".$canonical_query_string;

    // Generate the signature required by the Product Advertising API
    $signature = base64_encode(hash_hmac("sha256", $string_to_sign, $aws_secret_key, true));

    // Generate the signed URL
    $request_url = 'http://'.$endpoint.$uri.'?'.$canonical_query_string.'&Signature='.rawurlencode($signature);

    return $request_url;
  }

  /**
   * Formats api response as item array
   *
   * @param  SimpleXMLElement
   * 
   * @return Array
   */
  public function getItem($item) {
    return [
        'ASIN' => (String) $item->ASIN,
        'URL' => (String) $item->DetailPageURL,
        'IMAGE' => ((String) $item->MediumImage->URL) ? (String) $item->MediumImage->URL : 'img/image-unavailable.png',
        'TITLE' => (String) $item->ItemAttributes->Title,
        'BRAND' => (String) $item->ItemAttributes->Brand,
        'PartNumber' => (String) $item->ItemAttributes->PartNumber,
        'MANUFACTURER' => (String) $item->ItemAttributes->Manufacturer,
        'MPN' => (String) $item->ItemAttributes->MPN,
        'UPC' => (String) $item->ItemAttributes->UPC,
        'PRICE' => ((String) $item->OfferSummary->LowestNewPrice->FormattedPrice == "Too low to display") ? "99999999999" : (String) $item->OfferSummary->LowestNewPrice->Amount,
        'FORMATTEDPRICE' => ((String) $item->OfferSummary->LowestNewPrice->FormattedPrice == "Too low to display") ? "See retailer for more information" : (String) $item->OfferSummary->LowestNewPrice->FormattedPrice,
        'SALESRANK' => (String) $item->SalesRank,
        'REVIEWURL' => (String) $item->CustomerReviews->IFrameURL,
        'ENERGYUSE' => 9999
      ];
  }

  /**
   * Map ENERGY STAR estimated usage to category items
   *
   * @param  String
   * @param  Array
   * 
   * @return Array
   */
  public function addEnergyStarData($category, $items) {
    $data = $this->getEnergyStarData($category);
    foreach($items AS &$item) {
      foreach($data AS $row) {
        if (isset($row['upc']) && str_contains($row['upc'], $item['UPC'])) {
          $item['ENERGYUSE'] = $row[static::$EnergyFields[$category]];
          continue 2;
        }
      }

      foreach($data AS $row) {
        if ($row['brand_name'] == $item['BRAND'] && str_is($row['model_number'], $item['PartNumber'])) {
          $item['ENERGYUSE'] = $row[static::$EnergyFields[$category]];
          continue 2;
        }
      }
    }

    return $items;
  }

  /**
   * Makes REST Request to ENERGYSTAR API
   *
   * @param  string
   * 
   * @return GuzzleHttp\Response
   */
  public function getEnergyStarData($category) {
    return (new Client)->get(static::$Endpoints[$category])->json();
  }

}