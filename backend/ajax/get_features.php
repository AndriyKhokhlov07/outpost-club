<?php

	require_once('../../api/Backend.php');
	$backend = new Backend();
	
	$category_id = $backend->request->get('category_id', 'integer');
	$product_id = $backend->request->get('product_id', 'integer');
	
	if(!empty($category_id))
		$features = $backend->features->get_features(array('category_id'=>$category_id));
	else
		$features = $backend->features->get_features();
		
	$options = array();
	if(!empty($product_id))
	{
		$opts = $backend->features->get_product_options($product_id);
		foreach($opts as $opt)
			$options[$opt->feature_id] = $opt;
	}
		
	foreach($features as &$f)
	{
		if(isset($options[$f->id]))
			$f->value = $options[$f->id]->value;
		else
			$f->value = '';
	}

	header("Content-type: application/json; charset=UTF-8");
	header("Cache-Control: must-revalidate");
	header("Pragma: no-cache");
	header("Expires: -1");		
	print json_encode($features);
