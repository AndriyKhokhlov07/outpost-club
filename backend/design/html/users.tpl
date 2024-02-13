{* Вкладки *}
{capture name=tabs}
	<li class="active">
		<a href="index.php?module=UsersAdmin">
			{if !$type || $type==1}
				Guests
			{else if $type==2}
				House leaders
			{else if $type==3}
				Cleaners
			{/if}
		</a>
	</li>
	<li><a href="index.php?module=MoveInAdmin">Move In</a></li>
	<li><a href="index.php?module=FarewellAdmin">Farewell</a></li>
	
	{if in_array('issues', $manager->permissions)}<li><a href="index.php?module=IssuesAdmin">Technical Issues</a></li>{/if}

	{if in_array("menu_12", $manager->permissions)}
		<li><a href='?module=PagesAdmin&menu_id=12'>For House Leader</a></li>
	{/if}


	{*
	{if in_array('groups', $manager->permissions)}<li><a href="index.php?module=GroupsAdmin">Groups</a></li>{/if}
	{if in_array('coupons', $manager->permissions)}<li><a href="index.php?module=CouponsAdmin">Купоны</a></li>{/if}
	*}
{/capture}

{* Title *}
{$meta_title='Guests' scope=parent}

{* Поиск *}
{if $users || $keyword}
<form method="get">
<div id="search">
	<input type="hidden" name="module" value='UsersAdmin'>
	<input class="search" type="text" name="keyword" value="{$keyword|escape}" />
	<input class="search_button" type="submit" value=""/>
</div>
</form>
{/if}

{* Заголовок *}
<div id="header">
	{if $keyword && $users_count>0}
		<h1>
			Fond {$users_count} 
			{if !$type || $type==1}
				{$users_count|plural:'guest':'guests'}
			{else if $type==2}
				{$users_count|plural:'house leader':'house leaders'}
			{else if $type==2}
				{$users_count|plural:'cleaner':'cleaners'}
			{/if}
		</h1>
	{elseif $users_count>0}
		<h1>
			{$users_count} 
			{if !$type || $type==1}
				{$users_count|plural:'guest':'guests'}
			{else if $type==2}
				{$users_count|plural:'house leader':'house leaders'}
			{else if $type==3}
				{$users_count|plural:'cleaner':'cleaners'}
			{/if}
		</h1> 	
	{else}
		<h1>
			No
			{if !$type || $type==1}
				guests
			{else if $type==2}
				house leaders
			{else if $type==3}
				cleaners
			{/if}
		</h1> 	
	{/if}
	
	{if $users_count>0}
	<form method="post" action="{url module=ExportUsersAdmin}" target="_blank">
	<input type="hidden" name="session_id" value="{$smarty.session.id}">
	{* <input type="image" src="./design/images/export_excel.png" name="export" title="Export all guests"> *}
	</form>
	{/if}
	<a class="add" href="{url module=UserAdmin return=$smarty.server.REQUEST_URI}">Add new guest</a>
</div>

{if $users}
<!-- Основная часть -->
<div id="main_list">

	<!-- Листалка страниц -->
	{include file='pagination.tpl'}	
	<!-- Листалка страниц (The End) -->

	<div id="sort_links" style='display:block;'>
	<!-- Ссылки для сортировки -->
	Sort by
	{if $sort!='name'}<a href="{url sort=name}">name</a>{else}name{/if} or
	{if $sort!='date'}<a href="{url sort=date}">date</a>{else}date{/if}
	<!-- Ссылки для сортировки (The End) -->
	</div>

	<form id="form_list" method="post">
	<input type="hidden" name="session_id" value="{$smarty.session.id}">
	
		<div id="list">	
			{foreach $users as $user}
			<div class="{if !$user->enabled}invisible{/if} row">
		 		<div class="checkbox cell">
					<input type="checkbox" name="check[]" value="{$user->id}"/>				
				</div>
				<div class="user_name cell">
					<a href="index.php?module=UserAdmin&id={$user->id}">{$user->name|escape}</a>	
					{if $user->house_id && $rooms[$user->house_id]}
						<div class="sm">{$rooms[$user->house_id]->name|escape}</div>
					{/if}
					{if $user->type==2}
						<div class="st">House Leader</div>
					{/if}
				</div>
				<div class="user_email cell">
					<a href="mailto:{$user->name|escape}<{$user->email|escape}>">{$user->email|escape}</a>	
				</div>
				<div class="user_group cell">
					{$groups[$user->group_id]->name}
				</div>
				<div class="icons cell">
					<a class="enable" title="Активен" href="#"></a>
					<a class="delete" title="Удалить" href="#"></a>
				</div>
				<div class="clear"></div>
			</div>
			{/foreach}
		</div>
	
		<div id="action">
		<label id="check_all" class="dash_link">Select all</label>
	
		<span id=select>
		<select name="action">
			<option value="disable">Disable</option>
			<option value="enable">Enable</option>
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

 <!-- Меню -->
<div id="right_menu">
	{if $groups}	
	<ul>
		<li {if !$group->id}class="selected"{/if}><a href='index.php?module=UsersAdmin'>All groups</a></li>
		{foreach $groups as $g}
		<li {if $group->id == $g->id}class="selected"{/if}><a href="index.php?module=UsersAdmin&group_id={$g->id}">{$g->name}</a></li>
		{/foreach}
	</ul>
	{/if}



	{function name=houses_tree}
	{if $houses}
	<ul>
		{if $houses[0]->parent_id == 0}
			<li {if !$house->id}class="selected"{/if}><a href="{url house_id=null}">All houses</a></li>	
		{/if}
		{foreach $houses as $h}
			<li {if $house->id == $h->id}class="selected"{/if}>
				{if $h->parent_id == 0}
					{$h->name}
				{else}
					<a href="{url house_id=$h->id}">{$h->name}</a>
				{/if}
			</li>
			{if $h->subcategories}
				{houses_tree houses=$h->subcategories}
			{/if}
		{/foreach}
	</ul>
	{/if}
	{/function}
	{houses_tree houses=$houses}

	<ul>
		<li{if !$type} class="selected"{/if}><a href='index.php?module=UsersAdmin'>All profile types</a></li>
		<li{if $type==1} class="selected"{/if}><a href="{url keyword=null page=null type=1}">Guests</a></li>
		<li{if $type==2} class="selected"{/if}><a href="{url keyword=null page=null type=2}">House Leaders</a></li>
		<li{if $type==3} class="selected"{/if}><a href="{url keyword=null page=null type=3}">Cleaners</a></li>
	</ul>

		
</div>
<!-- Меню  (The End) -->


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
	
	// Выделить все
	$("#check_all").click(function() {
		$('#list input[type="checkbox"][name*="check"]').attr('checked', 1-$('#list input[type="checkbox"][name*="check"]').attr('checked'));
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
			data: {'object': 'user', 'id': id, 'values': {'enabled': state}, 'session_id': '{/literal}{$smarty.session.id}{literal}'},
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
		if($('#list input[type="checkbox"][name*="check"]:checked').length>0)
			if($('select[name="action"]').val()=='delete' && !confirm('Подтвердите удаление'))
				return false;	
	});
});

</script>
{/literal}
