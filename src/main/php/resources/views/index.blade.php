@extends('layout')

@section('page-title', 'Eco Shopper - Home')

@section('content')
@include('partials.category-selector')
<div class="usa-grid">
  <div class="usa-width-one-half home-top">
    
    <h3>Find the ENERGY STAR appliance that suits your needs:</h3>
    <ul>
      <li>See top-selling products.</li> 

      <li>Sort by price.</li> 

      <li>Compare energy efficiency.</li>                 
    </ul>

    <p>Your choice to buy ENERGY STAR labeled products makes a difference in the fight against climate change through superior energy efficiency.
    </p>
  </div>
  <div class="usa-width-one-half home-top">
    
    <img src="img/appliances2.jpg" alt="">
    
  </div>
</div>  
@stop
