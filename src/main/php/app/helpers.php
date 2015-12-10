<?php

if ( ! function_exists('format_title'))
{
	/**
	 * Formats passed string in title case
	 *
	 * @param  string
	 * @return string
	 */
	function format_title($string)
	{
		return ucwords(strtolower($string));
	}
}

if ( ! function_exists('format_get'))
{
	/**
	 * Encodes/escapes user input so that it is suitable as a GET parameter
	 *
	 * @param  string
	 * @return string
	 */
	function format_get($string)
	{
		return str_replace(['%2F', '%22'], ['%252F'], rawurlencode(trim($string)));
	}
}