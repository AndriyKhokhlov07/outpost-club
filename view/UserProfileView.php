<?PHP


 
require_once('View.php');

class UserProfileView extends View
{
	function fetch()
	{
		if(empty($this->user))
		{
			header('Location: '.$this->config->root_url.'/user/login');
			exit();
		}

		$guest = new stdClass;

		if(!empty($this->user->email))
		{
			//$billing = $this->tokeet->get_billing(array('email'=>$this->user->email));
			//print_r($billing); exit;

			if(!empty($this->user->main_info))
				$guest->main_info = $this->user->main_info;
			// tokeet off
			// else
			// 	$guest->main_info = $this->tokeet->get_guest(array('email'=>$this->user->email));


			

			if(!empty($guest->main_info))
			{
				$guest->booking_invoices = array();

				if(!empty($guest->main_info['bookings']))
				{
					foreach($guest->main_info['bookings'] as $booking_key)
					{
						// tokeet off
						// $booking = $this->tokeet->get_booking(array('key'=>$booking_key));

						// $rental = $this->tokeet->get_rental(array('key'=>$booking['rental_id']));
						if(!empty($booking['cost']))
							$booking['cost'] = json_decode($booking['cost']);
						// if(!empty($rental))
						// 		$booking['rental'] = $rental;

						$guest->bookings[] = $booking;

						if(!empty($booking['invoices']))
						{
							foreach($booking['invoices'] as $bi)
								$guest->booking_invoices[] = $bi;
						}
					}
				}
				// tokeet off
				// $guest->tokeet_account = $this->tokeet->account;
			}
		}

		// $rental = $this->tokeet->get_rental(array('key'=>'1297f469-9fd7-4050-883d-0a6e366942fa'));
		// print_r($rental); exit;
		// print_r($guest); exit;

		// if(!empty($guest['bookings']))
		// {
		//  	$booking_key = current($guest['bookings']);
		//  	$booking = $backend->tokeet->get_booking(array('key'=>$booking_key));
		//  	print_r($booking);
		// }
		//if(empty($guest))
		//	return false;	
		$this->design->assign('guest', $guest);	

	
		if($this->request->method('post') && $this->request->post('password'))
		{
			//$name			= $this->request->post('name');
			//$email			= $this->request->post('email');
			$password		= $this->request->post('password');
			
			//$this->design->assign('name', $name);
			//$this->design->assign('email', $email);
			
			// $this->db->query('SELECT count(*) as count FROM __users WHERE email=? AND id!=?', $email, $this->user->id);
			// $user_exists = $this->db->result('count');

			// if($user_exists)
			// 	$this->design->assign('error', 'user_exists');
			// elseif(empty($name))
			// 	$this->design->assign('error', 'empty_name');
			// elseif(empty($email))
			// 	$this->design->assign('error', 'empty_email');
			// elseif($user_id = $this->users->update_user($this->user->id, array('name'=>$name, 'email'=>$email)))
			// {
			// 	$this->user = $this->users->get_user(intval($user_id));
			// 	$this->design->assign('name', $this->user->name);
			// 	$this->design->assign('user', $this->user);
			// 	$this->design->assign('email', $this->user->email);				
			// }
			// else
			// 	$this->design->assign('error', 'unknown error');
			
			if(!empty($password))
			{
				$this->users->update_user($this->user->id, array('password'=>$password));
			}
	
		}
		else
		{
			// Передаем в шаблон
			$this->design->assign('name', $this->user->name);
			$this->design->assign('email', $this->user->email);		
		}
	
		// $orders = $this->orders->get_orders(array('user_id'=>$this->user->id));
		// $this->design->assign('orders', $orders);
		if(!empty($guest->main_info['name']))
			$this->design->assign('meta_title', $guest->main_info['name']);
		else
			$this->design->assign('meta_title', $this->user->name);
		return $this->design->fetch('user_profile.tpl');
	}
}
