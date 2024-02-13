<?
chdir('..');
require_once('api/Backend.php');
$backend = new Backend();

$allowed_image_extentions = array('png', 'gif', 'jpg', 'jpeg', 'ico');

$data = array();
if($backend->request->post('name')){

	foreach($backend->request->post('name') as $n=>$v)
	{
		if(!isset($data[$n]))
		{
			$data[$n] = new stdClass;
		}
		$data[$n]->name = $v;
	}
}
if($backend->request->post('value')){
	foreach($backend->request->post('value') as $n=>$v)
	{
		if(!isset($data[$n]))
		{
			$data[$n] = new stdClass;
		}
		$data[$n]->value = $v;
	}
}


$type = $backend->request->post('type');
$mail_to = $backend->request->post('mail_to');

if(!empty($data)){

	$files_arr = $backend->request->files('files');
	if(!empty($files_arr))
	{
		// Delete old files
		// $files = glob($backend->config->root_dir.$backend->config->tmp_dir."*");
		// $now   = time();
		// if(!empty($files))
		// {
		// 	foreach($files as $file)
		// 	{
		// 		if(is_file($file))
		// 		{
		// 			if($now - filemtime($file) >= 60 * 60 * 24 * 14) // 14 days
		// 				unlink($file);
		// 		}
		// 	}
		// }
		

		foreach ($files_arr['name'] as $k=>$files)
		{
			for($i=0; $i<count($files); $i++)
			{
				if($image_name = $backend->image->upload_image($files_arr['tmp_name'][$k][$i], $files_arr['name'][$k][$i], 'tmp'))
				{
					// Resize image
			 		$imagesize = getimagesize($backend->config->root_dir.$backend->config->tmp_dir.$image_name);
			 		if($imagesize[0] > 1000)
			 		{
			 			$backend->simpleimage->load($backend->config->root_dir.$backend->config->tmp_dir.$image_name);
						$backend->simpleimage->resizeToWidth(1000);
						$backend->simpleimage->save($backend->config->root_dir.$backend->config->tmp_dir.$image_name);
			 		}

					$data[$k]->images[] = $backend->config->root_url.'/'.$backend->config->tmp_dir.$image_name;
				}
			}
		}
	}


	foreach($data as $k=>$d)
	{
		if(empty($d->value) && empty($d->images))
			unset($data[$k]);
	}


	$backend->design->assign('data', $data);

	// TO
	$mailto = $backend->settings->comment_email;

	// FROM
	$mailfrom = $backend->settings->notify_from_email;

	$data_arr['content'] = 'Your message has been successfully sent.';

	// HouseLeader Checklist
	if($type == 'hl_checklist')
	{
		$backend->design->assign('subject_', $data[1]->value);
		$mailto = $backend->settings->checklists_email;
		$data_arr['content'] = 'Thank You!';
	}


	if(!empty($mail_to))
		$mailto = $mail_to;

	$email_template = $backend->design->fetch($backend->config->root_dir.'backend/design/html/email_forms_admin.tpl');
	$subject = $backend->design->get_var('subject');
	$backend->notify->email($mailto, $subject, $email_template, $mailfrom);


	if($type == 'hl_checklist')
		$backend->notify->email('molchanov.eugeniy@gmail.com', $subject, $email_template, $mailfrom);

	// Test email template:
	// $data_arr['content'] = $email_template;
		
	
}
else
	$data_arr['content'] = 'Failed to send data.<br> Try to refresh the page and try again.';

header("Content-type: application/json; charset=UTF-8");
header("Cache-Control: must-revalidate");
header("Pragma: no-cache");
header("Expires: -1");
echo json_encode($data_arr);