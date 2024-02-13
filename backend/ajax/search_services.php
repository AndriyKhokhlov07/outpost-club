<?php
require_once('../../api/Backend.php');
$backend = new Backend();
$limit = 100;
	
$keyword = $backend->request->get('query', 'string');
	
$keywords = explode(' ', $keyword);
$keyword_sql = '';
foreach($keywords as $keyword)
{
	$kw = $backend->db->escape(trim($keyword));
	$keyword_sql .= $backend->db->placehold("AND (p.name LIKE '%$kw%')");
}
	
$backend->db->query('SELECT 
						p.id,
						p.name
					FROM __pages p
	                WHERE 
						menu_id in (3, 4)
						'.$keyword_sql.' 
					ORDER BY p.name LIMIT ?',
					$limit);
$pages = $backend->db->results();
	
$suggestions = array();
foreach($pages as $page)
{
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