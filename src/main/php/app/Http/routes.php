<?php

/*
|--------------------------------------------------------------------------
| Application Routes
|--------------------------------------------------------------------------
|
| Here is where you can register all of the routes for an application.
| It's a breeze. Simply tell Laravel the URIs it should respond to
| and give it the controller to call when that URI is requested.
|
*/
Route::get('/', [ 'as' => 'index', function()
{
    return view('index', [ 'category' => null ]);
}]);

Route::get('results', [ 'as' => 'results', function()
{
    $category = Request::input('category');
    $categories = App\AmazonConnector::$Categories;

    $p = Request::has('p') ? Request::input('p') : 1;
    $sort = Request::input('sort');

    $awsConnector = new App\AmazonConnector;
    $allItems = $awsConnector->getCachedItems($category);
    $items = ($sort) ? $allItems->sortBy($sort)->forPage($p, 10) : $allItems->forPage($p, 10);
    $total = count($allItems);

    return view('results', compact('category', 'categories', 'sort', 'items', 'p', 'total'));
}]);

Route::get('refresh', [ 'as' => 'refresh', function()
{
    $exitCode = Artisan::call('refresh-results');
    return redirect()->route('index');
}]);