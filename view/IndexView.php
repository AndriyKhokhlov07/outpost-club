<?PHP


require_once('View.php');

class IndexView extends View
{	
	public $modules_dir = 'view/';

	public function __construct()
	{
		parent::__construct();
	}
	

	function initHousesNeBo() {
		// Request to NeBo
		$url = 'https://ne-bo.com/ajax/get_houses.php?prices_range=1';
		// if ($this->config->host == 'dev_') {
		// 	$url = 'https://nebo/ajax/get_houses.php';
		// }
		$curl = curl_init();
		curl_setopt($curl, CURLOPT_URL, $url);
		curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
		curl_setopt($curl, CURLOPT_CONNECTTIMEOUT, 5);
		$json = curl_exec($curl);
		$http_status = curl_getinfo($curl, CURLINFO_HTTP_CODE);
		curl_close($curl);
		if ($http_status == 200) {
			return $json;
		}
		return false;
	}
	
	function getHousesNeBo() {
		$result = false;
		if (strtotime($this->settings->nebo_houses_data) >= strtotime(date('Y-m-d'))) {
			$result = $this->settings->nebo_houses;
		} else {
			$result = $this->initHousesNeBo();
			$this->settings->nebo_houses = $result;
			$this->settings->nebo_houses_data = date('Y-m-d');
		}
		return (array)json_decode($result);
	}

		
	
	function fetch()
	{
		// Устанавливаем куку, чтоб показать всплывающее окно на подписку 1 раз
		SetCookie('md_subscription', 1);
		
		// SetCookie('md_subscription', 1, time() + 3600, '/', $this->config->root_url);
		
		$info = new stdClass;
		$info->houses = new stdClass;		
		$pages = $this->pages->get_pages(['visible'=>1]);
		if (!empty($pages)) {
			$nebo_houses_k = [];
			if ($nebo_houses = $this->getHousesNeBo()) {
				foreach ($nebo_houses as $h) {
					$nebo_houses_k[trim($h->header)] = $h->id;
				}
			}
			$houses = [];
			foreach ($pages as $p) {
				if ($p->menu_id == 5 && $p->parent_id != 0) {
					$p->city = $pages[$p->parent_id]->header;
					// NYC
					if ($p->parent_id == 253) {
						$p->region = 'NY';
					}
					// Philadelphia
					elseif ($p->parent_id == 427) {
						$p->region = 'PA';
					}
					$nebo_house = false;
					if (!empty($p->nebo_id) && isset($nebo_houses[$p->nebo_id])) {
						$nebo_house = $nebo_houses[$p->nebo_id];
					}
					elseif ($nebo_houses_k[trim($p->header)]) {
						$nebo_house = $nebo_houses[$nebo_houses_k[trim($p->header)]];
					}
					if ($nebo_house && $nebo_house->blocks2) {
						$p->is_nebo_data = true;
						$p->address = $nebo_house->blocks2->address;
						$p->street_address = $nebo_house->blocks2->street_address;
						$p->street_number = $nebo_house->blocks2->street_number;
						$p->postal = $nebo_house->blocks2->postal;
						if (empty($p->region)) {
							$p->region = $nebo_house->blocks2->region;
						}
						if (empty($p->city)) {
							$p->city = $nebo_house->blocks2->city;
						}
						if (empty($p->latitude)) {
							$p->latitude = $nebo_house->blocks2->latitude;
						}
						if (empty($p->longitude)) {
							$p->longitude = $nebo_house->blocks2->longitude;
						}
						if (isset($nebo_house->min_price)) {
							$p->min_price = $nebo_house->min_price;
							if (!isset($info->houses->min_price) || $info->houses->min_price > $nebo_house->min_price) {
								$info->houses->min_price = $nebo_house->min_price;
							}
						}
						if (isset($nebo_house->max_price)) {
							$p->max_price = $nebo_house->max_price;
							if (!isset($info->houses->max_price) || $info->houses->max_price < $nebo_house->max_price) {
								$info->houses->max_price = $nebo_house->max_price;
							}
						}
					}
					$houses[$p->id] = $p;
				}
			}
			$this->design->assign('houses', $houses);
		}
		$this->design->assign('info', $info);
		
		
		$pages = $this->pages->get_pages_tree();		
		$this->design->assign('pages', $pages);

		if(!empty($this->user))
		{
			// Категории товаров
			$this->design->assign('categories', $this->categories->get_categories_tree());
		}
		
		$this->design->assign('is_mobile', preg_match("/(android|avantgo|blackberry|bolt|boost|cricket|docomo|fone|hiptop|mini|mobi|palm|phone|pie|tablet|up\.browser|up\.link|webos|wos)/i", $_SERVER["HTTP_USER_AGENT"]));

		
		//$this->design->assign('plus14days', strtotime('+14 day'));
		$unixtime = time(); // your date in unix format 
		$this->design->assign('lastday', date('t', $unixtime));
							
		// Текущий модуль (для отображения центрального блока)
		$module = $this->request->get('module', 'string');
		$module = preg_replace("/[^A-Za-z0-9]+/", "", $module);

		if($this->request->this_url)
		{
			if(in_array($this->request->this_url, array('blog', 'tag', 'author')))
				$module = 'BlogView';
			elseif($this->page)
				$module = 'PageView';

			/*elseif($this->categories->get_category((string)$this->request->this_url))
				$module = 'ProductsView';
			
			elseif($this->products->get_product((int)( ((int)substr($this->request->this_url, 1) - (int)$this->config->staff_number) )))
				$module = 'ProductView';*/
		}
		elseif(empty($module))
			$module = 'MainView';

		$this->design->assign('this_url', $this->request->this_url);


		// Если не задан - берем из настроек
		if(empty($module))
			return false;
		//$module = $this->settings->main_module;


		if(in_array($module, array(
			'UserView',
			'UserProfileView',
			'HouseLeaderView',
			'CurrentMembersView',
			'LoginView',
			'MoveInView',
			'RegisterView',
			'RestockingView',
			'TechnicalIssuesView'
		)))
		{
			header('Location: https://ne-bo.com/user/login');
			exit();
		}

		// Создаем соответствующий класс
		if (is_file($this->modules_dir."$module.php"))
		{
				include_once($this->modules_dir."$module.php");
				if (class_exists($module))
				{
					$this->main = new $module($this);
				} else return false;
		} else return false;

		// Создаем основной блок страницы
		if (!$content = $this->main->fetch())
		{
			return false;
		}		

		// Передаем основной блок в шаблон
		$this->design->assign('content', $content);		
		
		// Передаем название модуля в шаблон, это может пригодиться
		$this->design->assign('module', $module);
				
		// Создаем текущую обертку сайта (обычно index.tpl)
		$wrapper = $this->design->smarty->getTemplateVars('wrapper');
		if(is_null($wrapper))
			$wrapper = 'index.tpl';

		if($this->page->id == 336)
			$wrapper = 'index_firewall.tpl';

		
		if(!empty($wrapper))
			return $this->body = $this->design->fetch($wrapper);
		else
			return $this->body = $content;

	}
}
