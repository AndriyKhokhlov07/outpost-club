<?php
	require_once('../../api/Backend.php');
	$backend = new Backend();
	$limit = 100;
	
	$keyword = $backend->request->get('query', 'string');
	
	$backend->db->query('SELECT u.id, u.name, u.email FROM __users u WHERE u.name LIKE "%'.$backend->db->escape($keyword).'%" OR u.email LIKE "%'.$backend->db->escape($keyword).'%"ORDER BY u.name LIMIT ?', $limit);
	$users = $backend->db->results();
	
	$suggestions = array();
	foreach($users as $user)
	{
		$suggestion = new stdClass();
		$suggestion->value = $user->name." ($user->email)";			
		$suggestion->data = $user;
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
