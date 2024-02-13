

<h2 style="font-family:arial;">{$title}<br> {$house->name}</h2>

<a style="font-family:arial;" href="{$config->root_url}/backend/?module=InventoriesAdmin&type={if $this->user->type==2}2{elseif $this->user->type==3}1{/if}&house_id={$house->id}">View in admin panel</a>

<p style="font-family:arial;">{$inventory->date|date_format:"%b %e, %Y"} at {$inventory->date|time}</p>
{if $user}
	<p style="font-family:arial;">{$user->name} ({$user->email})</p>
{/if}


<table cellpadding="6" cellspacing="0" style="border-collapse: collapse;">
{function name=groups_tree_ level=0}
	{if $groups_t}
		{foreach $groups_t as $g}

		{$subcategories_items=0}
		{if $g->subcategories}
			{foreach $g->subcategories as $sc}
				{if $sc->items}
					{$subcategories_items=1}
				{/if}
			{/foreach}
		{/if}

		{if $subcategories_items || $g->items}
			<tr>
				<td colspan="2" style="padding:10px; background-color:{if $level==0}#e6eaf0;{else}#f0f0f0;{/if}border:1px solid #e0e0e0;font-family:arial;{if $level==0}font-weight:800;{/if}">{$g->name|escape}</td>
			</tr>
			{groups_tree_ groups_t=$g->subcategories level=$level+1}
			
			{if $g->items}
				{foreach $g->items as $item}
					<tr>
						<td style="padding:10px; width:200; background-color:#fff; border:1px solid #e0e0e0;font-family:arial;">
							{$item->name|escape},
							{if $item->unit}
								{$item->unit|escape}
							{else}
								pcs.
							{/if}
						</td>

						<td style="padding:10px; width:170; background-color:#fff; border:1px solid #e0e0e0;font-family:arial; text-align:center;">
							<div>
								{if $inventory->values[{$g->id}][{$item->id}]}
									<span>{$inventory->values[{$g->id}][{$item->id}]->value}</span>
								{else}
									<span>0</span>
								{/if}
							</div>
						</td>
					</tr>
				{/foreach}
			{/if}
		
		{/if}
		{/foreach}
	{/if}
{/function}

{groups_tree_ groups_t=$groups_tree}
{if $inventory->note}
	<tr>
		<td colspan="2" style="padding:10px; background-color:#fff; border:1px solid #e0e0e0;font-family:arial;">
			{$inventory->note|escape}
		</td>
	</tr>
{/if}
</table>

{if $inventory->images}
<div style="margin: 20px 0">
	{foreach $inventory->images as $i}
		<a href="{$config->root_url}/{$config->inventories_images_dir}{$i}" target="_blank"><img src="{$config->root_url}/{$config->inventories_images_dir}{$i}" alt="" width="150"></a>
	{/foreach}
</div>
{/if}
