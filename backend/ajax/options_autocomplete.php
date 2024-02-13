<?php

	require_once('../../api/Backend.php');
	$backend = new Backend();
	$limit = 100;

	
	$keyword = $backend->request->get('query', 'string');
	$feature_id = $backend->request->get('feature_id', 'string');
	
	$query = $backend->db->placehold('SELECT DISTINCT po.value FROM __options po
										WHERE value LIKE "'.$backend->db->escape($keyword).'%" AND feature_id=? ORDER BY po.value LIMIT ?', $feature_id, $limit);

	$backend->db->query($query);
		
	$options = $backend->db->results('value');

	$res = new stdClass;
	$res->query = $keyword;
	$res->suggestions = $options;
	header("Content-type: application/json; charset=UTF-8");
	header("Cache-Control: must-revalidate");
	header("Pragma: no-cache");
	header("Expires: -1");		
	print json_encode($res);
