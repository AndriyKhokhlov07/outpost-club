<?
session_start();

require_once('../api/Backend.php');

$backend = new Backend();


if($backend->request->post('firstname'))
{
	$user = new stdClass;
	$user->name = $backend->request->post('firstname').' '.$backend->request->post('lastname');
	$user->first_name = $backend->request->post('firstname');
	$user->last_name = $backend->request->post('lastname');
	$user->email = $backend->request->post('email');
	$user->phone = $backend->request->post('phone');
	$user->type = 1;
	$user->status = 0;
	$user->enabled = 0;

	// hotel_upd
	if($backend->request->post('first_name___guest'))
	{
		$user->guest_name = $backend->request->post('first_name___guest').' '.$backend->request->post('guest_last_name');
		$user->guest_first_name = $backend->request->post('first_name___guest');
		$user->guest_last_name = $backend->request->post('guest_last_name');
		$user->guest_email = $backend->request->post('guest_email');
		$user->guest_phone = $backend->request->post('guest_phone_number');
	}
	// hotel_upd END

	$postData = (array)$user;

	$curl = curl_init();
	curl_setopt($curl, CURLOPT_URL, 'https://ne-bo.com/ajax/add_user.php');
	curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
	curl_setopt($curl, CURLOPT_POST, true);
	curl_setopt($curl, CURLOPT_CONNECTTIMEOUT, 5);
	curl_setopt($curl, CURLOPT_POSTFIELDS, http_build_query($postData));
	$json = curl_exec($curl);

	$http_status = curl_getinfo($curl, CURLINFO_HTTP_CODE);
	curl_close($curl);


	$data_arr['content'] = 'User added.';
}


header("Content-type: application/json; charset=UTF-8");
header("Cache-Control: must-revalidate");
header("Pragma: no-cache");
header("Expires: -1");
echo json_encode($data_arr);

// Log 
if(!empty($postData))
{
	logg('json: '.http_build_query($postData));	
}
elseif(!empty($_POST))
{
	foreach($_POST as $key=>$value)
		logg('post: '.$key.' => '.$value);
}
else
	logg('post empty');

function logg($str)
{
	file_put_contents('log.txt', file_get_contents('log.txt')."\r\n".date("m.d.Y H:i:s").' '.$_SERVER['REMOTE_ADDR'].' '.$str);
}