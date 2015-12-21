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
    return view('index', [
        'category' => null
    ]);
}]);

Route::get('results', [ 'as' => 'results', function()
{
    $category = Request::input('category');
    $p = Request::has('p') ? Request::input('p') : 1;
    $sort = Request::has('sort') ? Request::input('sort') : "SALESRANK";
    $awsConnector = new App\AmazonConnector;
    $allItems = $awsConnector->getItems($category);
    $total = count($allItems);
    $items = $allItems->sortByDesc($sort)->forPage($p, 10);

    return view('results', compact('category', 'items', 'p', 'total'));
}]);