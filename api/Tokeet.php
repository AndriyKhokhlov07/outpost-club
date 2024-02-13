<?php

require_once('Backend.php');

class Tokeet extends Backend
{
	public  $account = '1483704850.4948';
	private $apikey = 'c418bc9f-6254-4a53-b9c3-7acb5fa1a403';

	private $j_username = 'molchanov@me.com';
	private $j_password = 'Outpost2018';

	// Tokeet backend API
	private $auth_token;


	public function __construct()
	{
		if(isset($_SESSION['auth_token']))
			$this->auth_token = $_SESSION['auth_token'];
	}


	


	// CURL GET
	public function curl_get($params = array())
	{
		$type = '';
		$pkey = '';

		if(!empty($params['type']))
			$type = $params['type'];

		if(!empty($params['pkey']))
			$pkey = $params['pkey'];

		$curl = curl_init();

		curl_setopt_array($curl, array(
			CURLOPT_URL => 'https://capi.tokeet.com/v1/'.$type.'/'.$pkey.'?account='.$this->account,
			CURLOPT_RETURNTRANSFER => true,
			CURLOPT_ENCODING => "",
			CURLOPT_MAXREDIRS => 10,
			CURLOPT_TIMEOUT => 30,
			CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
			CURLOPT_CUSTOMREQUEST => "GET",
			CURLOPT_HTTPHEADER => array(
				'Authorization: '.$this->apikey
			),
		));

		$response = curl_exec($curl);
		$err = curl_error($curl);

		curl_close($curl);

		if($err)
		{
			echo "cURL Error #:".$err; exit;
		} 
		else 
		{
			$res = json_decode($response, true);
			unset($response);
			if(isset($res['data']))
				return $res['data'];
		}
	}

	// Use Tokeet backend API
	public function curl_get_v2($params = array())
	{
		$type = '';
		$pkey = '';
		$method = "GET";

		if(!empty($params['type']))
			$type = $params['type'];

		if(!empty($params['pkey']))
			$pkey = $params['pkey'];

		if(!empty($params['method']))
			$method = $params['method'];

		if(empty($this->auth_token))
		{
			$this->curl_authorization();
		}


		$curl = curl_init();

		curl_setopt_array($curl, array(
			CURLOPT_URL => 'https://api.tokeet.com/'.$type.'/'.$pkey,
			CURLOPT_RETURNTRANSFER => true,
			CURLOPT_ENCODING => "",
			CURLOPT_MAXREDIRS => 10,
			CURLOPT_TIMEOUT => 30,
			CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
			CURLOPT_CUSTOMREQUEST => $method,
			CURLOPT_HTTPHEADER => array(
				'Authorization: '.$this->auth_token
			),
		));

		$response = curl_exec($curl);


		curl_close($curl);
		$res = json_decode($response, true);
		unset($response);

		if(isset($res['error']))
		{
			if(empty($params['restart']))
			{
				$this->curl_authorization();
				$params['restart'] = 1;
				$this->curl_get_v2($params);
			}
			else
			{
				echo "cURL Error #:".$res['error']; exit;
			}
		}
		else
		{
			return $res;
		}
	}

	public function curl_authorization()
	{
		$data = array(
			"username" => $this->j_username, 
			"password" => $this->j_password
		);                                                                    
		$data_string = json_encode($data);                                                                                   
		                                                                                                                     
		$ch = curl_init('https://api.tokeet.com/user/login/');                                                                      
		curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "POST");                                                                     
		curl_setopt($ch, CURLOPT_POSTFIELDS, $data_string);                                                                  
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);                                                                      
		curl_setopt($ch, CURLOPT_HTTPHEADER, array(                                                                          
		    'Content-Type: application/json',                                                                                
		    'Content-Length: ' . strlen($data_string))                                                                       
		);                                                                                                                   
		                                                                                                                     
		$response = curl_exec($ch);
		$err = curl_error($ch);
		curl_close($ch);

		if($err)
		{
			echo "cURL Error #:".$err; exit;
		} 
		else 
		{
			$res = json_decode($response, true);
			unset($response);
			if(isset($res['token']))
			{
				$this->auth_token = $res['token'];
				$_SESSION['auth_token'] = $res['token'];
				return $this->auth_token;
			}
		}

	}



	// Guest
	public function get_guest($filter = array())
	{
		if(!empty($filter['email']))
			return $this->curl_get(array('type'=>'guest/email', 'pkey'=>$filter['email']));
	}

	// Booking
	public function get_booking($filter = array())
	{
		if(!empty($filter['key']))
			//return $this->curl_get(array('v2'=>true, 'type'=>'inquiry', 'pkey'=>$filter['key']));
			return $this->curl_get_v2(array('type'=>'inquiry', 'pkey'=>$filter['key']));
	}

	// Rental
	public function get_rental($filter = array())
	{
		if(!empty($filter['key']))
			return $this->curl_get(array('type'=>'rental', 'pkey'=>$filter['key']));
	}

	// Billing - not working!
	public function get_billing($filter = array())
	{
		// f3a23d6f-3baa-4614-a456-3ba135b7c23f
		// c2c59e28-ae40-44c1-b2cb-01423a061411
		if(!empty($filter['email']))
			return $this->curl_get(array('type'=>'billigs'));
	}

	
}
