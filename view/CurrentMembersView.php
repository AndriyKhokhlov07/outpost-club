<?PHP


 
require_once('View.php');

class CurrentMembersView extends View
{
	function fetch()
	{
		if(empty($this->user))
		{
			header("HTTP/1.1 301 Moved Permanently"); 
			header('Location: '.$this->config->root_url.'/user/login');
			exit();
		}

		$guest = new stdClass;

		if(!empty($this->user->email))
		{
			if(!empty($this->user->main_info))
				$guest->main_info = $this->user->main_info;
			// tokeet off
			// else
			// 	$guest->main_info = $this->tokeet->get_guest(array('email'=>$this->user->email));

			if(!empty($guest->main_info))
			{
				$guest->booking_invoices = array();
				$guest->booking_new_invoices = array();

				if(!empty($guest->main_info['bookings']))
				{
					foreach($guest->main_info['bookings'] as $booking_key)
					{
						$booking = $this->tokeet->get_booking(array('key'=>$booking_key));
						if(!empty($booking['cost']))
							$booking['cost'] = json_decode($booking['cost']);

						$guest->bookings[] = $booking;

						if(!empty($booking['invoices']))
						{
							foreach($booking['invoices'] as $bi)
							{
								$guest->booking_invoices[] = $bi;
								if($bi['status'] == 0 || $bi['status'] == 1)
									$guest->booking_new_invoices[] = $bi;
							}
						}
					}
				}
				$guest->tokeet_account = $this->tokeet->account;
			}
		}


		// Technical issues
		if(!empty($this->user->house_id))
		{
			$issues = $this->issues->get_issues(array('house_id'=>$this->user->house_id, 'visible'=>1, 'status'=>array(0, 1)));
			$this->design->assign('issues_statuses', array('Not started', 'In progress', 'Done'));
			$this->design->assign('issues', $issues);
		}

		// New Event and Product
		$products_ids = array();

		$new_event = $this->products->get_products(array('category_id'=>1, 'featured'=>1, 'visible'=>1, 'limit'=>1));
		if(!empty($new_event))
		{
			$new_event = current($new_event);
			$products_ids[] = $new_event->id;
		}

		$new_product = $this->products->get_products(array('category_id'=>2, 'featured'=>1, 'visible'=>1, 'limit'=>1));
		if(!empty($new_product))
		{
			$new_product = current($new_product);
			$products_ids[] = $new_product->id;
		}

		if(!empty($products_ids))
		{
			// Выбираем варианты
			$variants = $this->variants->get_variants(array('product_id'=>$products_ids, 'in_stock'=>true));
			if(!empty($variants))
			{
				foreach($variants as $variant)
				{
					if(!empty($new_event) && $new_event->id == $variant->product_id)
						$new_event->variants[] = $variant;
					if(!empty($new_product) && $new_product->id == $variant->product_id)
						$new_product->variants[] = $variant;
				}

			}
			
			// Выбираем изображения
			$images = $this->products->get_images(array('product_id'=>$products_ids));
			if(!empty($images))
			{
				foreach($images as $image)
				{
					if(!empty($new_event) && $new_event->id == $image->product_id)
						$new_event->images[] = $image;
					if(!empty($new_product) && $new_product->id == $image->product_id)
						$new_product->images[] = $image;
				}
			}

			if(!empty($new_event))
			{
				if(isset($new_event->variants[0]))
					$new_event->variant = $new_event->variants[0];
				if(isset($new_event->images[0]))
					$new_event->image = $new_event->images[0];
			}
			if(!empty($new_product))
			{
				if(isset($new_product->variants[0]))
					$new_product->variant = $new_product->variants[0];
				if(isset($new_product->images[0]))
					$new_product->image = $new_product->images[0];
			}

			//print_r($new_event); exit;

			$this->design->assign('new_event', $new_event);
			$this->design->assign('new_product', $new_product);
		}







		$this->design->assign('guest', $guest);

		return $this->design->fetch('current_members.tpl');
	}
}
