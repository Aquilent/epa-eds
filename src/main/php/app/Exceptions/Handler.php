<?php namespace App\Exceptions;

use Exception;
use Illuminate\Foundation\Exceptions\Handler as ExceptionHandler;
use GuzzleHttp\Exception\ClientException;
use GuzzleHttp\Exception\ConnectException;

class Handler extends ExceptionHandler {

	/**
	 * A list of the exception types that should not be reported.
	 *
	 * @var array
	 */
	protected $dontReport = [
		'Symfony\Component\HttpKernel\Exception\HttpException'
	];

	/**
	 * Report or log an exception.
	 *
	 * This is a great spot to send exceptions to Sentry, Bugsnag, etc.
	 *
	 * @param  \Exception  $e
	 * @return void
	 */
	public function report(Exception $e)
	{
		return parent::report($e);
	}

	/**
	 * Render an exception into an HTTP response.
	 *
	 * @param  \Illuminate\Http\Request  $request
	 * @param  \Exception  $e
	 * @return \Illuminate\Http\Response
	 */
	public function render($request, Exception $e)
	{
		// In debug mode display the exception
		if (config('app.debug')) return parent::render($request, $e);

		// Connect Exception asssume API was unavailable
		// if ($e instanceof ConnectException) return response()->view('errors.404', [], 404);

		// API Limit Reached Exception
		// if (($e instanceof ClientException) && $e->getCode() == 429) return response()->view('errors.429', [], 429);

		// Generic error page
		return response()->view('errors.500', [], 500);
	}

}
