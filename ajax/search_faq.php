<?php

require_once('../api/Backend.php');
$backend = new Backend();

$keyword = $backend->request->get('query', 'string');

$pages = $backend->pages->get_pages(array('keyword'=>$keyword, 'menu_id'=>6, 'not_parent_id'=>0, 'visible'=>1));

$suggestions = array();

if(!empty($pages))
{
	foreach($pages as $page)
	{
		$suggestion = new stdClass();			
		$suggestion->value = $page->name;
		$suggestion->data = $page;
		$suggestions[] = $suggestion;
	}
}

$res = new stdClass;
$res->query = $keyword;
$res->suggestions = $suggestions;
header("Content-type: application/json; charset=UTF-8");
header("Cache-Control: must-revalidate");
header("Pragma: no-cache");
header("Expires: -1");		
print json_encode($res);
