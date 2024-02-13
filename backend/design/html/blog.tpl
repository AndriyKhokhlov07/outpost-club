{* Вкладки *}
{capture name=tabs}
	<li {if $type==1} class="active" {/if}><a href="index.php?module=BlogAdmin&type=1">Blog</a></li>
	<li {if $type==2} class="active" {/if}><a href="index.php?module=BlogAdmin&type=2">Reviews</a></li>
	<li><a href="index.php?module=AuthorsAdmin">Authors</a></li>
	<li><a href="index.php?module=BlogTagsAdmin">Tags</a></li>
{/capture}

{* Title *}
{$meta_title='Blog' scope=parent}

{* Поиск *}
{if $posts || $keyword}
<form method="get">
<div id="search">
	<input type="hidden" name="module" value='BlogAdmin'>
	<input class="search" type="text" name="keyword" value="{$keyword|escape}" />
	<input class="search_button" type="submit" value=""/>
</div>
</form>
{/if}
		
{* Заголовок *}
<div id="header">
	{if $keyword && $posts_count}
	<h1>Found {$posts_count} {$posts_count|plural:'post':'posts'}</h1>
	{elseif $posts_count}
	<h1>{$posts_count} {$posts_count|plural:'post':'posts'} in blog</h1>
	{else}
	<h1>No posts</h1>
	{/if}
	<a class="add" href="{url module=PostAdmin return=$smarty.server.REQUEST_URI}">Add new post</a>
</div>	

{if $posts}
<div id="main_list">
	
	<!-- Листалка страниц -->
	{include file='pagination.tpl'}	
	<!-- Листалка страниц (The End) -->

	<form id="list_form" method="post">
	<input type="hidden" name="session_id" value="{$smarty.session.id}">
	
		<div id="list" class="sortable">
			{foreach $posts as $post}
			<div class="{if !$post->visible}invisible{/if} {if $post->featured}featured{/if} row">
				<input type="hidden" name="positions[{$post->id}]" value="{$post->position}">
				<div class="move cell" style="margin-left:{$level*20}px"><div class="move_zone"></div></div>

		 		<div class="checkbox cell">
					<input type="checkbox" name="check[]" value="{$post->id}" />				
				</div>
				<div class="name cell">		
					<a href="{url module=PostAdmin id=$post->id return=$smarty.server.REQUEST_URI}">{$post->name|escape}</a>
					<br>
					{$post->date|date}
				</div>
				<div class="icons cell">
					<a class="featured" title="Featured" href="#"></a>
					<a class="enable" title="Published" href="#"></a>
					<a class="delete" title="Delete" href="#"></a>
				</div>
				<div class="clear"></div>
			</div>
			{/foreach}
		</div>
		
	
		<div id="action">
		<label id="check_all" class="dash_link">Select all</label>
	
		<span id="select">
		<select name="action">
			<option value="enable">Publish</option>
			<option value="disable">Unpublish</option>
			<option value="delete">Delete</option>
		</select>
		</span>
	
		<input id="apply_action" class="button_green" type="submit" value="Apply">
		
		</div>
				
	</form>	

	<!-- Листалка страниц -->
	{include file='pagination.tpl'}	
	<!-- Листалка страниц (The End) -->
	
</div>
{/if}

{* On document load *}
{literal}

<script>
$(function() {

	// Раскраска строк
	function colorize()
	{
		$("#list div.row:even").addClass('even');
		$("#list div.row:odd").removeClass('even');
	}
	// Раскрасить строки сразу
	colorize();

	// Сделать хитом
	$("a.featured").click(function() {
		var icon        = $(this);
		var line        = icon.closest("div.row");
		var id          = line.find('input[type="checkbox"][name*="check"]').val();
		var state       = line.hasClass('featured')?0:1;
		icon.addClass('loading_icon');
		$.ajax({
			type: 'POST',
			url: 'ajax/update_object.php',
			data: {'object': 'post', 'id': id, 'values': {'featured': state}, 'session_id': '{/literal}{$smarty.session.id}{literal}'},
			success: function(data){
				icon.removeClass('loading_icon');
				if(state)
					line.addClass('featured');				
				else
					line.removeClass('featured');
			},
			dataType: 'json'
		});	
		return false;	
	});

	
	// Выделить все
	$("#check_all").click(function() {
		$('#list input[type="checkbox"][name*="check"]').attr('checked', $('#list input[type="checkbox"][name*="check"]:not(:checked)').length>0);
	});	

	// Удалить 
	$("a.delete").click(function() {
		$('#list input[type="checkbox"][name*="check"]').attr('checked', false);
		$(this).closest(".row").find('input[type="checkbox"][name*="check"]').attr('checked', true);
		$(this).closest("form").find('select[name="action"] option[value=delete]').attr('selected', true);
		$(this).closest("form").submit();
	});
	
	// Скрыт/Видим
	$("a.enable").click(function() {
		var icon        = $(this);
		var line        = icon.closest(".row");
		var id          = line.find('input[type="checkbox"][name*="check"]').val();
		var state       = line.hasClass('invisible')?1:0;
		icon.addClass('loading_icon');
		$.ajax({
			type: 'POST',
			url: 'ajax/update_object.php',
			data: {'object': 'blog', 'id': id, 'values': {'visible': state}, 'session_id': '{/literal}{$smarty.session.id}{literal}'},
			success: function(data){
				icon.removeClass('loading_icon');
				if(state)
					line.removeClass('invisible');
				else
					line.addClass('invisible');				
			},
			dataType: 'json'
		});	
		return false;	
	});
	
	// Подтверждение удаления
	$("form").submit(function() {
		if($('select[name="action"]').val()=='delete' && !confirm('Please, confirm deletion'))
			return false;	
	});
});

</script>
{/literal}