<?php


require_once('Backend.php');

class CategoriesTree extends Backend
{
	// Дерево категорий
	public $categories_tree;

	// Функция возвращает дерево категорий
	public function get_categories_tree($type, $data)
	{
		if(!isset($this->categories_tree[$type]))
			$this->init_categories($type, $data);
			
		return $this->categories_tree[$type];
	}

	

	// Инициализация категорий, после которой категории будем выбирать из локальной переменной
	private function init_categories($type, $categories)
	{
		// Дерево категорий
		$tree = new stdClass();
		$tree->subcategories = array();
		
		// Указатели на узлы дерева
		$pointers = array();
		$pointers[0] = &$tree;
		$pointers[0]->path = array();
		$pointers[0]->level = 0;
				
		$finish = false;
		// Не кончаем, пока не кончатся категории, или пока ниодну из оставшихся некуда приткнуть
		while(!empty($categories)  && !$finish)
		{
			$flag = false;
			// Проходим все выбранные категории
			foreach($categories as $k=>$category)
			{
				if(isset($pointers[$category->parent_id]))
				{
					// В дерево категорий (через указатель) добавляем текущую категорию
					$pointers[$category->id] = $pointers[$category->parent_id]->subcategories[] = $category;
					
					// Путь к текущей категории
					$curr = $pointers[$category->id];
					$pointers[$category->id]->path = array_merge((array)$pointers[$category->parent_id]->path, array($curr));
					
					// Уровень вложенности категории
					$pointers[$category->id]->level = 1+$pointers[$category->parent_id]->level;

					// Убираем использованную категорию из массива категорий
					unset($categories[$k]);
					$flag = true;
				}
			}
			if(!$flag) $finish = true;
		}
		
		// Для каждой категории id всех ее деток узнаем
		$ids = array_reverse(array_keys($pointers));
		foreach($ids as $id)
		{
			if($id>0)
			{
				$pointers[$id]->children[] = $id;

				if(isset($pointers[$pointers[$id]->parent_id]->children))
					$pointers[$pointers[$id]->parent_id]->children = array_merge($pointers[$id]->children, $pointers[$pointers[$id]->parent_id]->children);
				else
					$pointers[$pointers[$id]->parent_id]->children = $pointers[$id]->children;
			}
		}
		unset($pointers[0]);
		unset($ids);

		$this->categories_tree[$type] = $tree->subcategories;	
		if($type == 'product_categories')
			$this->categories->all_categories = $pointers;
		elseif($type == 'pages')
			$this->pages->all_pages = $pointers;
		elseif($type == 'galleries_categories')
			$this->galleries->all_categories = $pointers;
		elseif($type == 'inventories_groups')
			$this->inventories->all_groups = $pointers;
	}
}