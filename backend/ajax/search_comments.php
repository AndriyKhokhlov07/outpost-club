<?php
require_once('../../api/Backend.php');
$backend = new Backend();

$keyword = $backend->request->get('query', 'string');

$pages = $backend->blog->get_posts(array('type'=>2, 'keyword'=>$keyword, 'visible'=>1));

$suggestions = array();
foreach($pages as $page)
{
	if(!empty($page->image))
		$page->image = $backend->design->resize_modifier($page->image, 'page', 35, 35);
	
	$suggestion = new stdClass();
	$suggestion->value = $page->name;
	$suggestion->data = $page;
	$suggestions[] = $suggestion;
}

$res = new stdClass;
$res->query = $keyword;
$res->suggestions = $suggestions;
header("Content-type: application/json; charset=UTF-8");
header("Cache-Control: must-revalidate");
header("Pragma: no-cache");
header("Expires: -1");		
print json_encode($res);
