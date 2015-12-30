<div class="usa-grid usa-grid-example usa-grid-text">
    <div class="usa-width-one-whole app-top">
    <form action="{{ route('results') }}" class="appliance-form">
          <label for="options">ENERGY STAR appliances:</label>
          <select name="options" id="options" class="appliance-form" onchange="location = this.options[this.selectedIndex].value;">

            @if (!Route::is('results'))
                <option value="{{ route('index') }}">Select</option>
            @endif
            <option @if($category == 'dryers') selected="selected" @endif value="{{ route('results', ['category' => 'dryers']) }}">Clothes Dryers</option>
            <option @if($category == 'washers') selected="selected" @endif value="{{ route('results', ['category' => 'washers']) }}">Clothes Washers</option>
            <option @if($category == 'dishwashers') selected="selected" @endif value="{{ route('results', ['category' => 'dishwashers']) }}">Dishwashers</option>
            <option @if($category == 'freezers') selected="selected" @endif value="{{ route('results', ['category' => 'freezers']) }}">Freezers</option>
            <option @if($category == 'refrigerators') selected="selected" @endif value="{{ route('results', ['category' => 'refrigerators']) }}">Refrigerators</option>
        </select>
    </form>
</div>
</div>