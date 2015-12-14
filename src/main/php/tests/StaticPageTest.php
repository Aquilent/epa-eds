<?php

class StaticPageTest extends TestCase {

	/**
	 * Tests that Home page displays correctly
	 *
	 * @return void
	 */
	public function testHomePage()
	{
		$response = $this->route('GET', 'home');

		$this->assertResponseOk();
		$this->assertContains('PROTOTYPE-NAME-HERE', $response->getContent());
	}

	/**
	 * Tests that Disclaimers page is viewable
	 *
	 * @return void
	 */
	public function testDisclaimersPage()
	{
		$response = $this->call('GET', 'disclaimers');

		$this->assertResponseOk();
		$this->assertContains('About the Data', $response->getContent());
	}

}
