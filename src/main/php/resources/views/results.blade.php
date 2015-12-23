@extends('layout')

@section('content')

@include('partials.category-selector')

<div class="usa-grid">
<div class="usa-width-one-whole">
      <div class="filter-container clearfix">
          <div class="filter-container-left">{{ $total }} Certified {{ $categories[$category] }}</div>
          <div class="filter-container-right clearfix">
              <div class="sort-left">Sort:</div>
              <div class="sort-right">
                <form action="" class="filter-form">
                  <select name="options" id="options" class="usa-input-tiny" onchange="location = this.options[this.selectedIndex].value;">
                    <option @if(!$sort || $sort == 'SALESRANK') selected="selected" @endif value="{{ route('results', [ 'category' => $category ]) }}">Top Seller</option>
                    <option @if($sort == 'ENERGYUSE') selected="selected" @endif value="{{ route('results', [ 'category' => $category, 'sort' => 'ENERGYUSE' ]) }}">Energy Use</option>
                    {{-- <option @if($sort == 'REVIEWS.starRating') selected="selected" @endif value="{{ route('results', [ 'category' => $category, 'sort' => 'REVIEWS.starRating' ]) }}">Star Rating</option> --}}
                    <option @if($sort == 'PRICE') selected="selected" @endif value="{{ route('results', [ 'category' => $category, 'sort' => 'PRICE' ]) }}">Price</option>
                </select>
            </form>
        </div>
    </div>
</div>

@foreach($items AS $item) 
<div class="product-result clearfix">
    <a href="{{ $item['URL'] }}" target="_blank"><div class="product-result-left">
      <img src="{{ $item['IMAGE'] }}">
  </div>
  <div class="product-result-right">
      <h5>{{ $item['TITLE'] }}</h5>
      <p class="prod-data">
          <span class="gray">By: {{ $item['BRAND'] }}</span><br />
          Estimated Annual Energy Use (kWh/yr): {{ $item['ENERGYUSE'] }}<br />
          Price: {{ $item['FORMATTEDPRICE'] }}<br />

          {{-- <span class="rating-stars">
              @for ($i = 1; $i <= 5; $i++)
              @if($item['REVIEWS']['starRating'] >= $i)
              <i class="fa fa-star"></i>
              @else
              <i class="fa fa-star-o"></i>
              @endif
              @endfor 
              <span class="star-num">({{ $item['REVIEWS']['reviewCount']}})</span>
          </span> --}}
          
          <span class="result-ES-logo"><img src="img/ES_learn_more_vert.jpg" alt="Logo image" style="margin-left: 0px;"></span>
      </p>
  </div></a>
</div>
@endforeach

@if ($total/10 > 1)
<ul class="pagination pagination-sm">
    @for ($i = 1; $i < ($total/10 + 1); $i++)
    @if ($p == $i)
    <li class="active"><a href="#">{{ $i }}</a></li>
    @else
    <li><a href="{{ route('results', [ 'category' => $category, 'sort' => $sort, 'p' => $i ]) }}">{{ $i }}</a></li>
    @endif
    @endfor
</ul>
@endif

</div>
</div>  
@stop

@section('return-link')
    <div class="usa-grid usa-footer-return-to-top top clearfix">
      <a href="#top">Return to top <i class="fa fa-caret-up"></i></a>
    </div>
@stop
