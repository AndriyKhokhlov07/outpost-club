<?PHP


require_once('View.php');

class BlogView extends View
{
	public function fetch()
	{
		$url = $this->request->get('url', 'string');

		$author_url = $this->request->get('author', 'string');
		$tag_url = $this->request->get('blog_category', 'string');
		
		if(!empty($author_url)) 
		{
			return $this->fetch_blog($type="author", $author_url);
		}

		if(!empty($tag_url)) 
		{
			return $this->fetch_blog($type="tag", $tag_url);
		}


		// Если указан адрес поста,
		if(!empty($url))
		{
			// Выводим пост
			return $this->fetch_post($url);
		}
		else
		{
			// Иначе выводим ленту блога
			return $this->fetch_blog($type="", $url="");
		}
	}
	
	private function fetch_post($url)
	{
		// Выбираем пост из базы
		$post = $this->blog->get_post($url);

		// Если не найден - ошибка
		if(!$post || (!$post->visible && empty($_SESSION['admin'])))
			return false;
		
		if(!empty($post))
		{
            // review
            // redirect to all reviews page
            if ($post->type == 2) {
                header("HTTP/1.1 301 Moved Permanently");
                header('Location: '.$this->config->root_url.'/reviews/');
            }


			// Tags
			$post->tags = $this->blog->get_tags(array('post_id'=>$post->id, 'visible'=>1));
			// Authors
			$post->authors = $this->blog->get_authors(array('post_id'=>$post->id, 'visible'=>1));
            if (!empty($post->authors)) {
                $post->author = current($post->authors);
            }
		}

		if (!is_null($post->date_modified)) {
			$this->request->last_modified = $post->date_modified;
		}
		else {
			$this->request->last_modified = $post->date;
		}
		


		$this->design->assign('post', $post);

		// Соседние записи
		$this->design->assign('next_post', $this->blog->get_next_post($post->id, $post->type));
		$this->design->assign('prev_post', $this->blog->get_prev_post($post->id, $post->type));
		
		// Мета-теги
		$this->design->assign('meta_title', $post->meta_title);
		$this->design->assign('meta_keywords', $post->meta_keywords);
		$this->design->assign('meta_description', $post->meta_description);
		
		return $this->design->fetch('post.tpl');
	}	
	
	// Отображение списка постов
	private function fetch_blog($type, $url)
	{

		$posts_authors = array();
		$posts_tags = array();

		$view = $this->request->get('view', 'string');


		// Количество постов на 1 странице
		$items_per_page = 8;

		$filter = array();
		
		// Выбираем только видимые посты
		$filter['visible'] = 1;
		$filter['date_to'] = date('Y-m-d H:i:s');
		$filter['type'] = 1;
		if ($view == 'reviews') {
			$filter['type'] = 2;

            $houses = $this->pages->get_pages([
                'menu_id' => 5,
                'not_parent_id' => 0,
                'visible' => 1
            ]);
		}

		if($type == "author")
		{
			if(!empty($url))
			{
				$author = $this->blog->get_authors(array('url'=>$url));
				if(!empty($author))
				{
					$filter['author_id'] = $author->id;
				}
			}
		}
		elseif($type == "tag")
		{
			if(!empty($url))
			{
				$tag = $this->blog->get_tags(array('url'=>$url));
				{
					$filter['tag_id'] = $tag->id;
				}
				// print_r($filter); exit;
			}
		}
		
		// Текущая страница в постраничном выводе
		$current_page = $this->request->get('page', 'integer');
		
		// Если не задана, то равна 1
		$current_page = max(1, $current_page);
		$this->design->assign('current_page_num', $current_page);

		// Вычисляем количество страниц
		$posts_count = $this->blog->count_posts($filter);

		// Показать все страницы сразу
		if($this->request->get('page') == 'all')
			$items_per_page = $posts_count;	

		$pages_num = ceil($posts_count/$items_per_page);
		$this->design->assign('total_pages_num', $pages_num);


		$filter['page'] = $current_page;
		if($type != "tag"){
			$filter['limit'] = $items_per_page;
		}


		
		


		// Выбираем статьи из базы
		$posts = array();
		$posts_ = $this->blog->get_posts($filter);

		if(empty($posts_))
		{
			return false;
		}
		else
		{
			if(!empty($posts_))
			{
				foreach($posts_ as $p)
				{
                    if ($view == 'reviews') {
                        $t = explode('/', $p->meta_title);
                        if (isset($t[0])) {
                            $p->author = trim($t[0]);
                        }
                        foreach ($houses as $h) {
                            if(preg_match_all("/($h->name)/", $p->name, $matches)) {
                                $p->house = $h;
                                $p->name = str_replace($h->name, '<a href="'.$h->url.'">'.$h->name.'</a>', $p->name);
                            }
                        }
                    }
					$posts[$p->id] = $p;
				}
				unset($posts_);
			}

			$posts_ids = array_keys($posts);


			// Tags
			
			$posts_tags_ = $this->blog->get_tags(array('post_id'=>$posts_ids, 'visible'=>1));
			if(!empty($posts_tags_))
			{
				foreach($posts_tags_ as $t)
					$posts_tags[$t->id] = $t;

				$posts_tags_ids = $this->blog->get_posts_tags(array('post_id'=>$posts_ids));
				foreach($posts_tags_ids as $pt)
				{
					if(isset($posts[$pt->post_id]) && isset($posts_tags[$pt->tag_id]))
						$posts[$pt->post_id]->tags_ids[$pt->tag_id] = $pt->tag_id;
				}
				unset($posts_tags_, $posts_tags_ids);
			}
			$this->design->assign('posts_tags', $posts_tags);
			

			// Authors
			$posts_authors_ = $this->blog->get_authors(array('post_id'=>$posts_ids, 'visible'=>1));
			if(!empty($posts_authors_))
			{
				foreach($posts_authors_ as $a)
					$posts_authors[$a->id] = $a;

				$posts_authors_ids = $this->blog->get_posts_authors(array('post_id'=>$posts_ids));
				foreach($posts_authors_ids as $pa)
				{
					if(isset($posts[$pa->post_id]) && isset($posts_authors[$pa->author_id]))
						$posts[$pa->post_id]->authors_ids[$pa->author_id] = $pa->author_id;
				}
				unset($posts_authors_, $posts_authors_ids);
			}
			$this->design->assign('posts_authors', $posts_authors);
		}
		
		// Передаем в шаблон
		$this->design->assign('posts', $posts);
		
		$page_url = 'blog';
		if ($view == 'reviews') {
			$page_url = $view;
		}
		
		// Метатеги
		$page = $this->pages->get_page_init($page_url);
		if(!empty($page))
		{
			$this->design->assign('page', $page);
			$this->design->assign('meta_title', $page->meta_title);
		}
		// Метатеги
		if($this->page)
		{
			$this->design->assign('meta_title', $this->page->meta_title);
			$this->design->assign('meta_keywords', $this->page->meta_keywords);
			$this->design->assign('meta_description', $this->page->meta_description);
		}
		if(!empty($tag))
		{
			$this->design->assign('tag', $tag);
			$this->design->assign('meta_title', $tag->meta_title);
			$this->design->assign('meta_description', $tag->meta_description);
		}

		if(!empty($author))
		{
			$this->design->assign('author', $author);
			$this->design->assign('meta_title', $author->name);
			$this->design->assign('meta_description', $author->name);
		}

		$tpl = 'blog.tpl';
        if ($view == 'reviews') {
            $tpl = 'pages/reviews.tpl';
        }

		return $this->design->fetch($tpl);
	}	
}