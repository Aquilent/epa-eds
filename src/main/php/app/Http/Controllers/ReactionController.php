<?php namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\FDAConnector;

class ReactionController extends Controller {

	/*
	|--------------------------------------------------------------------------
	| Reaction Controller
	|--------------------------------------------------------------------------
	|
	| This controller renders the search and results pages for the application
	|
	*/

	protected $fda;

	/**
	 * Create a new controller instance.
	 *
	 * @return void
	 */
	public function __construct(FDAConnector $fda)
	{
		$this->fda = $fda;
		$this->middleware('guest');
	}

	/**
	 * Handles search form submit
	 *
	 * @return Response
	 */
	public function getReactions(Request $request)
	{
		// Validate that atleast one drug was entered
		if (!($request->has('drugOne') || $request->has('drugTwo'))) {
			return redirect()->route('home')->withError('Please enter at least one drug name for your search.');
		}

		// Redirect to the listReactions route
		return redirect()->route('listReactions', [ format_get($request->drugOne), format_get($request->drugTwo) ]);
	}

	/**
	 * Displays a list of drug reactions
	 *
	 * @return Response
	 */
	public function listReactions(Request $request, $drugOne, $drugTwo = null)
	{
		// Store current value of show query param so that we return to the correct page
		session()->flash('show', $request->get('show'));

		// Query for all reactions
		$reactions = $this->limitResults($this->fda->getDrugReactions($drugOne, $drugTwo));
		
		// Render reactions view
		return view('reactions', compact('drugOne', 'drugTwo', 'reactions'));
	}

	/**
	 * Displays demographic information for the current drug reaction
	 *
	 * @return Response
	 */
	public function listInteractions(Request $request, $reaction, $drugOne, $drugTwo = null)
	{

		// Gather necessary data for the view
		$data = [
			'drugOne'		=>	$drugOne,
			'drugTwo'		=>	$drugTwo,
			'reaction' 	=> 	$reaction,
			'total'			=> 	$this->fda->getDrugReactionTotal($reaction, $drugOne, $drugTwo),
			'genders'		=>	$this->fda->getDrugReactionGender($reaction, $drugOne, $drugTwo),
			'ages'			=>	$this->fda->getDrugReactionAge($reaction, $drugOne, $drugTwo),
			'weights'		=>	$this->fda->getDrugReactionWeight($reaction, $drugOne, $drugTwo)
		];

		// Render demographics view
		return view('demographics', $data);
	} 

	/**
	 * Limits results array to the first 10
	 *
	 * @return Response
	 */
	protected function limitResults($results) 
	{
		if (app('request')->get('show') == 'all') return $results;

		return collect($results)->take(10)->toArray();
	}

}
