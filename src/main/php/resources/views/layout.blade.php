<!-- layout.nunjucks -->

<!DOCTYPE html>
<html lang="en”>
<!--[if lt IE 7]>      <html class="no-js lt-ie9 lt-ie8 lt-ie7"> <![endif]-->
<!--[if IE 7]>         <html class="no-js lt-ie9 lt-ie8"> <![endif]-->
<!--[if IE 8]>         <html class="no-js lt-ie9"> <![endif]-->
<!--[if gt IE 8]><!--> <html class="no-js"> <!--<![endif]-->
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <title>@yield('page-title')</title>
    <meta name="description" content="">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta data-name="last-updated" data-content="{{ Cache::get('last_updated') }}" />

      <!-- Place favicon.ico and apple-touch-icon.png in the root directory -->
      <link rel="stylesheet" href="css/main.css">
      <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.5.0/css/font-awesome.min.css">
</head>
    <body>
        <!--[if lt IE 7]>
            <p class="browsehappy">You are using an <strong>outdated</strong> browser. Please <a href="http://browsehappy.com/">upgrade your browser</a> to improve your experience.</p>
        <![endif]-->

    <!-- You write code for this content block in another file -->
     
  @if (Route::is('index'))
    <header class="header">
      <section class="usa-grid">
        <div class="usa-width-one-half logo">
            <a href="{{ route('index') }}"><img src="img/eco-shop-logo-3.png" alt="Eco shopper Home Page"></a>
        </div>
        <div class="usa-width-one-half header-tag-line">
            <h4>Search for top-selling ENERGY STAR&reg; rated appliances on Amazon.com </h4>
        </div>
      </section>
    </header>
  @else 
    <header class="header">
      <section class="usa-grid">
        <div class="usa-width-one-half logo">
            <a href="{{ route('index') }}"><img src="img/eco-shop-logo-results-3.png" alt="Eco shopper Home Page"></a>
        </div>
      </section>
    </header>
  @endif


  <main id="content" class="group" role="main">
    @yield('content')
  </main>

  <footer class="usa-footer usa-footer-slim usa-sans" role="contentinfo">
    @yield('return-link')
    <div class="usa-footer-primary-section">
      <div class="usa-grid-full footer-left">
        
        <p>The eco&#9734;shopper application bridges information and action. It is designed to display and sort only ENERGY STAR appliances in order of buying popularity, energy efficiency and price. eco&#9734;shopper is your single-source of information to make an informed ENERGY STAR purchase – protecting the climate as a result.</p>
        
      </div>
    </div>

    <div class="usa-footer-secondary_section">
      <div class="usa-grid">
        <div class="usa-footer-logo footer-right">
          <a href="http://www.aquilent.com" style="box-shadow: none;"><img src="img/aquilent-logo-new.png" alt="Aquilent"></a>
          <p>Developed by Aquilent &copy; 2015 - {{ Carbon\Carbon::now()->year }} | All rights reserved.</p>
        </div>
      </div>
    </div>
  </footer>



        <script src="//ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>
        <script>window.jQuery || document.write('<script src="js/vendor/jquery-1.11.3.min.js"><\/script>')</script>
        <script src="js/components.js"></script>
        <script type="text/javascript" src="js/jquery.mmenu.min.all.js"></script>
        <script type="text/javascript">
            $(function() {
                $('nav#filter-menu').mmenu();
            });
        </script>

        

        <!-- Google Analytics: change UA-XXXXX-X to be your site's ID. -->
        <script>
            (function(b,o,i,l,e,r){b.GoogleAnalyticsObject=l;b[l]||(b[l]=
            function(){(b[l].q=b[l].q||[]).push(arguments)});b[l].l=+new Date;
            e=o.createElement(i);r=o.getElementsByTagName(i)[0];
            e.src='//www.google-analytics.com/analytics.js';
            r.parentNode.insertBefore(e,r)}(window,document,'script','ga'));
            ga('create','UA-XXXXX-X');ga('send','pageview');
        </script>
    </body>
</html>