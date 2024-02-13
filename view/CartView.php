<?PHP

 
require_once('View.php');

class CartView extends View
{

	public function __construct()
	{
		parent::__construct();

		// Если передан id варианта, добавим его в корзину
		if($variant_id = $this->request->get('variant', 'integer'))
		{
			$this->cart->add_item($variant_id, $this->request->get('amount', 'integer'));




			if(!empty($this->user->id))
			{
				$order = new stdClass;
	    		$order->user_id = $this->user->id;
	    		$order->email   = $this->user->email;
	    		$order->type    = 2; // Order
	    		$order->ip 		= $_SERVER['REMOTE_ADDR'];


	    		if(!empty($this->user->main_info))
					$user_info = $this->user->main_info;
				else
					$user_info = $this->tokeet->get_guest(array('email'=>$this->user->email));


				if(!empty($user_info))
				{

			    	if(!empty($user_info['name']))
			    		$order->name = $user_info['name'];
			    	elseif(!empty($this->user->name))
			    		$order->name = $this->user->name;

			    	if(!empty($user_info['phones']))
			    		$order->phone = current($user_info['phones']);
			    	elseif(!empty($user_info['phone']))
			    		$order->phone = $user_info['phone'];

			    	if(!empty($this->user->house_id))
			    	{
						$house = $this->pages->get_page((int)$this->user->house_id);
						if(!empty($house))
						{
							$order->address = $house->header;
						}
			    	}

				}

				// Добавляем заказ в базу
		    	$order_id = $this->orders->add_order($order);
		    	$_SESSION['order_id'] = $order_id;

		    	$this->orders->add_purchase(array('order_id'=>$order_id, 'variant_id'=>intval($variant_id), 1));

		    	$order = $this->orders->get_order($order_id);

		    	// Вариант оплаты PayPal для товаров дороже 0
		    	if($order->total_price > 0)
		    	{
		    		$this->orders->update_order($order->id, array('payment_method_id'=>4));
		    	}

		    	// Отправляем письмо пользователю
				$this->notify->email_order_user($order->id);

		    	// Отправляем письмо администратору
				$this->notify->email_order_admin($order->id);

				// Очищаем корзину (сессию)
				$this->cart->empty_cart();

				//print_r($order); exit;

				// Перенаправляем на страницу заказа
				header('Location: '.$this->config->root_url.'/order/'.$order->url);

				//print_r($user_info); exit;
			}

		    
			
		}     
	}

	function fetch()
	{  

		//header('location: '.$this->config->root_url.'/cart/');
		return $this->design->fetch('cart.tpl');
		
	}
	
}