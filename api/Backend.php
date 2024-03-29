<?php


class Backend
{
	// Свойства - Классы API
	private $classes = array(
		'config'     => 'Config',
		'request'    => 'Request',
		'db'         => 'Database',
		'settings'   => 'Settings',
		'design'     => 'Design',
		'categories_tree' => 'CategoriesTree',
		'galleries'	 => 'Galleries',
		'pages'      => 'Pages',
		'loans'		 => 'Loans',
		'blog'       => 'Blog',
		'simpleimage'=> 'SimpleImage',
		'image'      => 'Image',
		'comments'   => 'Comments',
		'feedbacks'  => 'Feedbacks',
		'issues'     => 'Issues',
		'notify'     => 'Notify',
		'managers'   => 'Managers',
		'users'      => 'Users',
		'tokeet' 	 => 'Tokeet',
		'products'   => 'Products',
		'variants'   => 'Variants',
		'categories' => 'Categories',
		'brands'     => 'Brands',
		'features'   => 'Features',
		'money'      => 'Money',
		'cart'       => 'Cart',
		'delivery'   => 'Delivery',
		'payment'    => 'Payment',
		'orders'     => 'Orders',
		'coupons'    => 'Coupons',
		'inventories'=> 'Inventories'
	);
	
	// Созданные объекты
	private static $objects = array();
	
	/**
	 * Конструктор оставим пустым, но определим его на случай обращения parent::__construct() в классах API
	 */
	public function __construct()
	{
		//error_reporting(E_ALL & !E_STRICT);
	}

	/**
	 * Магический метод, создает нужный объект API
	 */
	public function __get($name)
	{
		// Если такой объект уже существует, возвращаем его
		if(isset(self::$objects[$name]))
		{
			return(self::$objects[$name]);
		}
		
		// Если запрошенного API не существует - ошибка
		if(!array_key_exists($name, $this->classes))
		{
			return null;
		}
		
		// Определяем имя нужного класса
		$class = $this->classes[$name];
		
		// Подключаем его
		include_once(dirname(__FILE__).'/'.$class.'.php');
		
		// Сохраняем для будущих обращений к нему
		self::$objects[$name] = new $class();
		
		// Возвращаем созданный объект
		return self::$objects[$name];
	}
}