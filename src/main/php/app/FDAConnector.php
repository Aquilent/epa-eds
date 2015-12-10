<?php namespace App;

use GuzzleHttp\Client;
use GuzzleHttp\Exception\ClientException;

class FDAConnector {

  /**
   * FDAClient instance
   */
  protected $client;

  /**
   * Create a new connector instance.
   *
   * @return void
   */
  public function __construct(FDAClient $client) {
    $this->client = $client;
  }

  /**
   * Return list of drug reactions
   *
   * @return array
   */
  public function getDrugReactions($drugOne, $drugTwo = null) {
    return $this->client->getResults([
      'search' => $this->buildSearchTerm($drugOne, $drugTwo),
      'count'  => 'patient.reaction.reactionmeddrapt.exact'
    ]);
  }

  /**
   * Return total number of reports for drug reaction
   *
   * @return int
   */
  public function getDrugReactionTotal($reaction, $drugOne, $drugTwo = null) {
    return $this->client->getTotal([
      'search' => $this->buildSearchTerm($drugOne, $drugTwo, $reaction),
    ]);
  }

  /**
   * Return list of drug interactions
   *
   * @return array
   */
  public function getDrugReactionInteractions($reaction, $drugOne, $drugTwo = null) {
    $interactions =  $this->client->getResults([
      'search' => $this->buildSearchTerm($drugOne, $drugTwo, $reaction),
      'count'  => 'patient.drug.medicinalproduct.exact',
    ]);

    // First interaction will always be drugOne
    array_shift($interactions);

    // Second interaction will be drugTwo when passed
    if ($drugTwo) array_shift($interactions);

    return $interactions;
  }

  /**
   * Return gender counts for the drug reaction
   *
   * @return array
   */
  public function getDrugReactionGender($reaction, $drugOne, $drugTwo = null) {
    $totals['Male'] = $this->client->getTotal([
      'search' => $this->buildSearchTerm($drugOne, $drugTwo, $reaction) . '+AND+patient.patientsex:1',
    ]);

    $totals['Female'] = $this->client->getTotal([
      'search' => $this->buildSearchTerm($drugOne, $drugTwo, $reaction) . '+AND+patient.patientsex:2',
    ]);

    $totals['Unknown'] = $this->client->getTotal([
      'search' => $this->buildSearchTerm($drugOne, $drugTwo, $reaction) . '+AND+patient.patientsex:0',
    ]);

    $totals['Not Reported'] = $this->client->getTotal([
      'search' => $this->buildSearchTerm($drugOne, $drugTwo, $reaction) . '+AND+_missing_:patient.patientsex',
    ]);

    return $this->formatReturn($totals);
  }

  /**
   * Return age counts for the drug reaction
   *
   * @return array
   */
  public function getDrugReactionAge($reaction, $drugOne, $drugTwo = null) {
    $totals['< 1'] =  $this->client->getTotal([
      'search' => $this->buildSearchTerm($drugOne, $drugTwo, $reaction) . '+AND+' . $this->buildAgeSearchTerm(-100, 1)
    ]);

    $totals['1 to 17'] =  $this->client->getTotal([
      'search' => $this->buildSearchTerm($drugOne, $drugTwo, $reaction) . '+AND+' . $this->buildAgeSearchTerm(1, 18)
    ]);

    $totals['18 to 34'] =  $this->client->getTotal([
      'search' => $this->buildSearchTerm($drugOne, $drugTwo, $reaction) . '+AND+' . $this->buildAgeSearchTerm(18, 35)
    ]);

    $totals['35 to 54'] =  $this->client->getTotal([
      'search' => $this->buildSearchTerm($drugOne, $drugTwo, $reaction) . '+AND+' . $this->buildAgeSearchTerm(35, 55)
    ]);

    $totals['55 to 64'] =  $this->client->getTotal([
      'search' => $this->buildSearchTerm($drugOne, $drugTwo, $reaction) . '+AND+' . $this->buildAgeSearchTerm(55, 65)
    ]);

    $totals['> 65'] =  $this->client->getTotal([
      'search' => $this->buildSearchTerm($drugOne, $drugTwo, $reaction) . '+AND+' . $this->buildAgeSearchTerm(65, 10000)
    ]);

    $totals['Not Reported'] =  $this->client->getTotal([
      'search' => $this->buildSearchTerm($drugOne, $drugTwo, $reaction) . '+AND+_missing_:(patient.patientonsetage+patient.patientonsetageunit)'
    ]);

    return $this->formatReturn($totals);
  }

  /**
   * Return weight counts for the drug reaction
   *
   * @return array
   */
  public function getDrugReactionWeight($reaction, $drugOne, $drugTwo = null) {
    $totals[' < 50 LBS'] = $this->client->getTotal([
      'search' => $this->buildSearchTerm($drugOne, $drugTwo, $reaction) . '+AND+' . $this->buildWeightSearchTerm(0, 50),
    ]);

    $totals['50 to 99 LBS'] = $this->client->getTotal([
      'search' => $this->buildSearchTerm($drugOne, $drugTwo, $reaction) . '+AND+' . $this->buildWeightSearchTerm(50, 100),
    ]);

    $totals['100 to 149 LBS'] = $this->client->getTotal([
      'search' => $this->buildSearchTerm($drugOne, $drugTwo, $reaction) . '+AND+' . $this->buildWeightSearchTerm(100, 150),
    ]);

    $totals['150 to 199 LBS'] = $this->client->getTotal([
      'search' => $this->buildSearchTerm($drugOne, $drugTwo, $reaction) . '+AND+' . $this->buildWeightSearchTerm(150, 200),
    ]);

    $totals['200 to 249 LBS'] = $this->client->getTotal([
      'search' => $this->buildSearchTerm($drugOne, $drugTwo, $reaction) . '+AND+' . $this->buildWeightSearchTerm(200, 250),
    ]);

    $totals['> 250 LBS'] = $this->client->getTotal([
      'search' => $this->buildSearchTerm($drugOne, $drugTwo, $reaction) . '+AND+' . $this->buildWeightSearchTerm(250, 10000),
    ]);

    $totals['Not Reported'] = $this->client->getTotal([
      'search' => $this->buildSearchTerm($drugOne, $drugTwo, $reaction) . '+AND+_missing_:patient.patientweight',
    ]);

    return $this->formatReturn($totals);
  }

  /**
   * Builds the basic search term for a reaction
   *
   * @return string
   */
  protected function buildSearchTerm($drugOne, $drugTwo = null , $reaction = null) {
    $term = 'patient.drug.medicinalproduct.exact:' . $this->formatQueryString($drugOne);
    if ($drugTwo) $term .= '+AND+patient.drug.medicinalproduct.exact:' . $this->formatQueryString($drugTwo); 
    if ($reaction) $term .= '+AND+patient.reaction.reactionmeddrapt.exact:' . $this->formatQueryString($reaction);

    return '(' . $term . ')';
  }

  /**
   * Builds age search term for a reaction
   *
   * @return string
   */
  protected function buildAgeSearchTerm($from, $to) {
    $delta = .001; // delta to prevent values at the upper boundary from being counted twice

    // Age can be stored in multiple different units, perform the conversion from years here
    $terms[] = '(patient.patientonsetageunit:800+AND+patient.patientonsetage:[' . ($from * .1) . '+TO+' . (($to * .1) - $delta) . '])'; // Decades
    $terms[] = '(patient.patientonsetageunit:801+AND+patient.patientonsetage:[' . ($from) . '+TO+' . (($to) - $delta) . '])'; // Years
    $terms[] = '(patient.patientonsetageunit:802+AND+patient.patientonsetage:[' . ($from * 12) . '+TO+' . (($to * 12) - $delta) . '])'; // Months
    $terms[] = '(patient.patientonsetageunit:803+AND+patient.patientonsetage:[' . ($from * 52) . '+TO+' . (($to * 52) - $delta) . '])'; // Weeks
    $terms[] = '(patient.patientonsetageunit:804+AND+patient.patientonsetage:[' . ($from * 365) . '+TO+' . (($to * 365) - $delta) . '])'; // Days
    $terms[] = '(patient.patientonsetageunit:805+AND+patient.patientonsetage:[' . ($from * 8760) . '+TO+' . (($to * 8760) - $delta) . '])'; // Hours

    // Return all subterms here in a giant or clause
    return '(' . implode('+', $terms) . ')';
  }

  /**
   * Builds weight search term for a query.  Mainly converts pounds to kilograms (1lb = .453592 kg)
   *
   * @return string.
   */
  protected function buildWeightSearchTerm($from, $to) {
    return '(patient.patientweight:[' . ($from * 0.453592) . '+TO+' . (($to * 0.453592) - .001) . '])';
  }

  /**
   * Formats drug names for querying the fda api.
   *
   * All caps, spaces to plus signs, and wrap in double qoutes
   *
   * @return string.
   */
  protected function formatQueryString($string) {
    return '"' . str_replace(' ', '+', strtoupper($string)) . '"';
  }

  /**
   * Creates normalized array of value objects for table display
   *
   * @return string.
   */
  protected function formatReturn($totals) {
    foreach($totals AS $key => $total) {
      $return[] = (object) ['term'=> $key, 'count'=> $total];
    }
    return $return;
  }

}