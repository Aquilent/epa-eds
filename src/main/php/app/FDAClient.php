<?php namespace App;

use GuzzleHttp\Client;
use GuzzleHttp\Exception\ClientException;

class FDAClient {

  /**
   * GuzzleHttp Client instance
   */
  protected $client;

  /**
   * Base uri for open fda api
   */
  protected $baseUri = 'https://api.fda.gov';

  /**
   * Adverse drug event endpoint
   */
  protected $drugUrl = '/drug/event.json';

  /**
   * Query count used to cycle api keys
   */
  protected $count = 0;

  /**
   * Create a new client instance.
   *
   * @return void
   */
  public function __construct() {
    $this->client = new Client(['base_uri' => $this->baseUri]);
  }

  /**
   * Perform a seach query and return the results
   *
   * @return array
   */
  public function getResults($query) {
    try {
      $response = $this->sendQuery($query);
      return $response->results;
    }
    catch(ClientException $e) {
      // Bad request or no result found errors return an empty array
      if ($e->getCode() == 404 || $e->getCode() == 400) return [];
      throw $e;
    }
  }

  /**
   * Perform a seach query and return the total reports found
   *
   * @return int
   */
  public function getTotal($query) {
    try {
      $response = $this->sendQuery($query);
      return $response->meta->results->total;
    }
    catch(ClientException $e) {
      // Bad request or no result found errors return 0
      if ($e->getCode() == 404 || $e->getCode() == 400) return 0;
      throw $e;
    }
  }
  
  /**
   * Sends query to the open fda api and returns the response
   *
   * @return object
   */
  protected function sendQuery($query, $retry = true) {
    $url = $this->formatUrl($query);
    info('Requesting: ' . $url);

    try {
      $response = $this->client->get($url);
    }
    catch(ClientException $e) {
      // Wait one second and retry the request if we recieve a 429 error
      if (($e->getCode() == 429) && $retry) {
        info('too many requests.... retrying query');;
        sleep(1);
        return $this->sendQuery($query, false);
      }


      // Log and throw the error
      $message = json_decode($e->getResponse()->getBody()->getContents())->error->message;
      logger()->error($message, compact('url'));
      throw $e;
    }

    // Return json decoded body
    return json_decode($response->getBody()->getContents());
  }

  /**
   * Builds the request url, adding any query params
   *
   * @return object
   */
  public function formatUrl($query) {
    $url = $this->baseUri . $this->drugUrl . '?' . $this->getAPIKey();
    foreach($query AS $param => $value) {
      $url .= '&' . $param . '=' . $value;
    }
    return $url;
  }

  /**
   * Return api key to be used for the api request
   *
   * Cycles api keys set in the openfda_api_key environment variable on a per request basis
   *
   * @return string
   */
  protected function getAPIKey() {
    if (env('OPENFDA_API_KEY')) {
      $keys = explode(',', env('OPENFDA_API_KEY'));
      $index = $this->count++ % count($keys);
      return 'api_key=' . trim($keys[$index]);
    }
  }
}