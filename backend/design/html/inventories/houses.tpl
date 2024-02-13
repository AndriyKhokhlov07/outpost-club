{* Вкладки *}
{capture name=tabs}

	<li {if $type==1}class="active"{/if}>
		<a href="index.php?module=InventoriesHousesAdmin&type=1">Restocking</a>
		{if $new_restokings[1]}
			<div class='counter'>{$new_restokings[1]['count']}</div>
		{/if}
	</li>
	<li {if $type==2}class="active"{/if}>
		<a href="index.php?module=InventoriesHousesAdmin&type=2">Kitchen restocking</a>
		{if $new_restokings[2]}
			<div class='counter'>{$new_restokings[2]['count']}</div>
		{/if}
	</li>

	<li><a href="index.php?module=InventoriesGroupsAdmin">Groups</a></li>
	<li><a href="index.php?module=InventoriesItemsAdmin">Items</a></li>
{/capture}

{$title = 'Restocking'}
{if $type==2}
	{$title = 'Kitchen restocking'}
{/if}


{* Title *}
{$meta_title=$title scope=parent}

{* Заголовок *}
<div id="header">
	<h1>{$title}</h1> 
</div>	

{if $houses}
<div id="main_list" class="inventories_houses">

	{function name=house_select level=0}
	{if $houses_}
		<div id="list">
		{foreach $houses_ as $house}
			<div class="row">
				<div class="tree_row">
					<div class="cell" style="margin-left:{$level*20}px">
						{if $level==0}
							{$house->name|escape}
						{else}
							<a href="{url module=InventoriesAdmin house_id=$house->id type=$type return=$smarty.server.REQUEST_URI}">{$house->name|escape}</a>
						{/if}
						{if $new_restokings[$type][$house->id]}
							<div class='counter'>{$new_restokings[$type][$house->id]}</div>
						{/if}
					</div>

					<div class="clear"></div>
				</div>

				{if $house->subcategories}
					{house_select houses_=$house->subcategories level=$level+1}
				{/if}
			</div>
			
		{/foreach}
		</div>
	{/if}
	{/function}
	{house_select houses_=$houses}
	
</div>
{else}
	No houses
{/if}
 
 