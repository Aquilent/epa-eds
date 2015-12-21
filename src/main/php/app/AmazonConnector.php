<?php namespace App;

use GuzzleHttp\Client;
use GuzzleHttp\Exception\ClientException;

class AmazonConnector {

  public $BrowseNodes = [
    'dryers' => 13397481,
    'washers' => 13397491,
    'dishwashers' => 3741271,
    'freezers' => 3741331,
    'refrigerators' => 3741361
  ];

  public function makeRequest($category, $page) {
    $client = new Client();
    $response = $client->get($this->signRequest($category, $page), [
    ]);

    //dd(json_decode(json_encode($response->xml()->Items)));

    return $response;
  }

  public function getItems($category = 'washers') {
    $items = [];

    for ($i = 1; $i <= 1; $i++) {
      foreach($this->makeRequest($category, $i)->xml()->Items->Item AS $item) {
        try {
          $items[] = $this->getItem($item);
        }
        catch(\Exception $e) {
          dd(json_decode(json_encode($item)));
        }
        
      }
    }

    return collect($items);
  }

  public function getItem($item) {
    //if (!(String) $item->MediumImage->URL) dd(json_decode(json_encode($item)));
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
        'PRICE' => ((String) $item->OfferSummary->LowestNewPrice->FormattedPrice == "Too Low To Display") ? 0 : (String) $item->OfferSummary->LowestNewPrice->Amount,
        'FORMATTEDPRICE' => (String) $item->OfferSummary->LowestNewPrice->FormattedPrice,
        'SALESRANK' => (String) $item->SalesRank,
        'REVIEWS' => $this->getReviewHtml($item),
        'ENERGYUSE' => 608
      ];
  }

  public function getReviewHtml($item) {
    // return [
    //   'starRating' => "0",
    //   'reviewCount' => "0"
    // ];

    $url = (String) $item->CustomerReviews->IFrameURL;
    $client = new Client();
    $response = $client->get($url);
    $body = trim((String) $response->getBody());

    libxml_use_internal_errors(true);
    $dom = new \DOMDocument;
    $dom->loadHtml($body);
    $xml = simplexml_import_dom($dom);

    $elements = $xml->xpath('//span[@class="crAvgStars"]');

    if ($elements) {
      $e = $elements[0];
      return [
        'starRating' => explode(" ", (String) $e->span->a->img['title'])[0],
        'reviewCount' => explode(" ", (String) $e->a)[0]
      ];
    }

    return [
      'starRating' => "0",
      'reviewCount' => "0"
    ];
  }

  public function signRequest($category, $page) {

    // Your AWS Access Key ID, as taken from the AWS Your Account page
    $aws_access_key_id = "AKIAJNRLVHW3Z7PE5WMA";

    // Your AWS Secret Key corresponding to the above ID, as taken from the AWS Your Account page
    $aws_secret_key = "tCpN+e7LRq0lHDuDi6UtY+wC0qCeE/9o/r3VXdbd";

    // The region you are interested in
    $endpoint = "webservices.amazon.com";

    $uri = "/onca/xml";

    $params = array(
        "Service" => "AWSECommerceService",
        "Operation" => "ItemSearch",
        "AWSAccessKeyId" => "AKIAJNRLVHW3Z7PE5WMA",
        "AssociateTag" => "sideambi-20",
        "SearchIndex" => "Appliances",
        "Keywords" => "Energy Star",
        "ResponseGroup" => "Images,ItemAttributes,Reviews,SalesRank,OfferSummary,Offers",
        "ItemPage" => $page,
        "Sort" => "salesrank",
        "BrowseNode" => $this->BrowseNodes[$category]
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

}