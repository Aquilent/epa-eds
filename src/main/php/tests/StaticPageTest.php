<?php

use App\AmazonConnector;

class StaticPageTest extends TestCase {

	/**
	 * Tests that Home page displays correctly
	 *
	 * @return void
	 */
	public function testIndexPage()
	{
		$response = $this->route('GET', 'index');

		$this->assertResponseOk();
		$this->assertContains('Eco Shopper - Home', $response->getContent());
	}

	/**
	 * Tests that Home page displays correctly
	 *
	 * @return void
	 */
	public function testBackgroundTask()
	{
		// Clear cache
		Cache::flush();

		// Run background task
		$exitCode = Artisan::call('refresh:results');

		// Assert job ran successfully
		$this->assertEquals(0, $exitCode);

		// Check that cache values were set
		foreach(array_keys(AmazonConnector::$Categories) AS $category) {
			$this->assertTrue(Cache::has($category));
		}
	}

	/**
	 * Tests that Disclaimers page is viewable
	 *
	 * @return void
	 */
	public function testResultsPage()
	{
		$response = $this->route('GET', 'results', ['category' => 'washers']);

		$this->assertResponseOk();
		$this->assertContains('Certified Clothes Washers', $response->getContent());
	}

}
