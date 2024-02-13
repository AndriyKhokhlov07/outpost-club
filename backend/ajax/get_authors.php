<?php

ini_set('error_reporting', E_ALL);
	require_once('../../api/Backend.php');
	$backend = new Backend();
	$limit = 100;
	
	$keyword = $backend->request->get('query', 'string');
	
	$keywords = explode(' ', $keyword);
	$keyword_sql = '';
	foreach($keywords as $keyword)
	{
		$kw = $backend->db->escape(trim($keyword));
		$keyword_sql .= $backend->db->placehold("AND (a.name LIKE '%$kw%')");
	}
	
	
	$query = $backend->db->placehold("SELECT 
						a.id, 
						a.image, 
						a.name
					FROM __authors a
	                WHERE 1 $keyword_sql ORDER BY a.name LIMIT ?", $limit);
	
	$backend->db->query($query);	
	$authors = $backend->db->results();

	$suggestions = array();
	if(!empty($authors))
	{
		foreach($authors as $author)
		{
			if(!empty($author->image))
				$author->image = $backend->design->resize_modifier($author->image, 'author', 35, 35);
			
			$suggestion = new stdClass();
			$suggestion->value = $author->name;
			$suggestion->data = $author;
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
