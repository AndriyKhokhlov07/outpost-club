<?PHP

/**
 * Backend CMS
 *
 * @copyright 	2011 Denis Pikusov
 * @link 		http://simp.la
 * @author 		Denis Pikusov
 *
 * Базовый класс для всех View
 *
 */

require_once('api/Backend.php');

class View extends Backend
{
	/* Смысл класса в доступности следующих переменных в любом View */
	public $currency;
	public $currencies;
	public $page;
	public $user;
	
	/* Класс View похож на синглтон, храним статически его инстанс */
	private static $view_instance;
	
	public function __construct()
	{
		parent::__construct();
		
		// Если инстанс класса уже существует - просто используем уже существующие переменные
		if(self::$view_instance)
		{
			$this->currency     = &self::$view_instance->currency;
			$this->currencies   = &self::$view_instance->currencies;
			$this->page = &self::$view_instance->page;	
			$this->user         = &self::$view_instance->user;
			// $this->group        = &self::$view_instance->group;	
		}
		else
		{
			// Сохраняем свой инстанс в статической переменной,
			// чтобы в следующий раз использовать его
			self::$view_instance = $this;

			// Все валюты
			$this->currencies = $this->money->get_currencies(array('enabled'=>1));
	
			// Выбор текущей валюты
			if($currency_id = $this->request->get('currency_id', 'integer'))
			{
				$_SESSION['currency_id'] = $currency_id;
				header("Location: ".$this->request->url(array('currency_id'=>null)));
			}
			
			// Берем валюту из сессии
			if(isset($_SESSION['currency_id']))
				$this->currency = $this->money->get_currency($_SESSION['currency_id']);
			// Или первую из списка
			else
				$this->currency = reset($this->currencies);



			// Пользователь, если залогинен
			if(isset($_SESSION['user_id']))
			{
				$u = $this->users->get_user(intval($_SESSION['user_id']));
				if($u && $u->enabled)
				{
					$this->user = $u;
					//$this->user->main_info = $this->tokeet->get_guest(array('email'=>$this->user->email));
					if(empty($_SESSION['user_name']))
					{
						// tokeet off
						// $this->user->main_info = $this->tokeet->get_guest(array('email'=>$this->user->email));
						if(!empty($this->user->main_info['name']))
							$_SESSION['user_name'] =  $this->user->main_info['name'];
						else
							$_SESSION['user_name'] =  $this->user->name;
						if(!empty($this->user->main_info['phones']))
							$_SESSION['user_phone'] = current($this->user->main_info['phones']);
						elseif(!empty($this->user->main_info['phone']))
							$_SESSION['user_phone'] =  $this->user->main_info['phone'];
					}
					//$this->group = $this->users->get_group($this->user->group_id);
				
				}
			}	

			$url_parts = explode('?', $_SERVER['REQUEST_URI'], 2);
			$url_part = $url_parts[0];
			$url_get_params = '';
			if(isset($url_parts[1]))
				$url_get_params = '?' . $url_parts[1];

			if (preg_match('/[[:upper:]]/', $url_part)) {
				$url_part = strtolower($url_part);
				header('HTTP/1.1 301 Moved Permanently'); 
				header('Location: https://' . $_SERVER["SERVER_NAME"] . $url_part . $url_get_params);
				exit;
			}

			// Posts redirects 
			$bc_301 = $this->blog->get_posts(array('old_url'=>1));
			if(!empty($bc_301)) {
				foreach($bc_301 as $pc)
				{
					if($url_part == '/' . $pc->old_url)
					{
						header("HTTP/1.1 301 Moved Permanently");
						header("Location: ".$this->config->root_url."/blog/".$pc->url);
						exit;
					}
				}			
			}
			else {

			}

			// Pages redirects 
			$pr_301 = $this->pages->get_pages(array('old_url'=>1));
			if(!empty($pr_301))
			{
				foreach($pr_301 as $pr)
				{
					if($url_part == '/'.$pr->old_url)
					{
						header("HTTP/1.1 301 Moved Permanently");
						header("Location: ".$this->config->root_url."/".$pr->url);
						exit;
					}
				}			
			}
			

			// Текущая страница (если есть)
			$subdir = substr(dirname(dirname(__FILE__)), strlen($_SERVER['DOCUMENT_ROOT']));
			$page_url = trim(substr($_SERVER['REQUEST_URI'], strlen($subdir)),"/");
			if(strpos($page_url, '?') !== false)
				$page_url = substr($page_url, 0, strpos($page_url, '?'));
			$this->page = $this->pages->get_page((string)$page_url);
            // FAQ
            if (!empty($this->page->blocks2)) {
                $this->page->blocks2 = unserialize($this->page->blocks2);
            }
			$this->design->assign('page', $this->page);	

			$this->design->assign('currencies',	$this->currencies);
			$this->design->assign('currency',	$this->currency);


			if (!is_null($this->page->date_modified)) {
				$this->request->last_modified = $this->page->date_modified;
			}



			$apply_button_text = 'Apply for free';
			

			// The Williamsburg House
			if($this->page->id == 413) 
				$apply_button_text = 'Check Availability';


			$apply_link = false;

			// The Maison Jefferson
			if($this->page->id == 439) {
				$apply_link = 'join-us-maison-on-jefferson';
			}
			// Cassa Studios
			elseif($this->page->id == 424) {
				$apply_link = 'cassa-application';
			}
			// Philadelphia
			elseif($this->page->parent_id == 427) {
				$apply_link = 'philadelphia-application';
			}
			// Neighborhood: Manhattan
			elseif($this->page->neighborhood == 1) {
				$apply_link = 'join-us-manhattan';
			}
			// Neighborhood: Brooklyn
			elseif($this->page->neighborhood == 2) {
				$apply_link = 'online-questionnaire';
			}
			$this->design->assign('apply_link', $apply_link);

			$this->design->assign('apply_button_text', $apply_button_text);


			$this->design->assign('avalability_button_text', 'Check Availability');



			$this->design->assign('config',		$this->config);
			$this->design->assign('settings',	$this->settings);
			$this->design->assign('user',       $this->user);

			// Настраиваем плагины для смарти
			$this->design->smarty->registerPlugin("function", "get_pages", array($this, 'get_pages_plugin'));
			$this->design->smarty->registerPlugin("function", "get_posts", array($this, 'get_posts_plugin'));
			$this->design->smarty->registerPlugin("function", "get_partners", array($this, 'get_partners_plugin'));

		}
	}

	/**
	 *
	 * Отображение
	 *
	 */
	function fetch()
	{
//        $review_text = $this->get_posts_plugin();
//        foreach($review_text as $rt) {
//        }
//        echo($review_text);exit();
		return false;
	}
	
	/**
	 *
	 * Плагины для смарти
	 *
	 */	
	public function get_pages_plugin($params, &$smarty)
	{
		if(!isset($params['visible']))
			$params['visible'] = 1;
		if(!empty($params['var']))
			$smarty->assign($params['var'], $this->pages->get_pages($params));
	}
	public function get_posts_plugin($params, &$smarty)
	{
		if(!isset($params['visible']))
			$params['visible'] = 1;
		if(!empty($params['var'])) {
            $posts = $this->blog->get_posts($params);
            if ($params['type'] == 2) {
                $houses = $this->pages->get_pages([
                    'menu_id' => 5,
                    'not_parent_id' => 0,
                    'visible' => 1
                ]);
                foreach ($posts as $p) {
                    $p->name_has_link = true;
                    foreach ($houses as $h) {
                        $p->name = str_replace($h->name, '<a href="'.$h->url.'">'.$h->name.'</a>', $p->name);
                    }
                }
            }
            $smarty->assign($params['var'], $posts);
        }
    }

    public function get_partners_plugin($params, &$smarty)
	{
		if(!isset($params['visible']))
			$params['visible'] = 1;
		if(!empty($params['var']))
			$smarty->assign($params['var'], $this->galleries->get_images(array('gallery_id'=>2)));
	}

}


