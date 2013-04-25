var giftique = (function($){
	var init = function(){
		$('#welcome').modal('show');

		//event handlers
		$('#travel-btn').on("click",function(){
			$('#main-menu').hide("slide", { direction: "left" },function(){
				$('#travel').show("slide", { direction: "right" }, function(){ loadMap(); });
			});
		});
	};

	var loadMap = function(){
		$('#map').vectorMap({
			map: 'world_mill_en',
			backgroundColor: 'transparent',

			series: {
				regions: [{
					values: gdpData,
					scale: ['#C8EEFF', '#0071A4'],
					normalizeFunction: 'polynomial'
				}]
			},
			hoverOpacity: 0.7,
			hoverColor: false,
			onRegionClick: function(event,str){
				var v = map.getRegionName(str),
				searches = [{name: "l1", val: v+" souvenir"},
				{name: "l2", val: v+" clothing"},
				{name: "l3", val: v+" gift"},
				{name: "l4", val: v+" custom"}];
				//etsysearch(searches);
			}
		});
		var map = $('#map').vectorMap('get','mapObject');
	};

	var textModule = function(){
		
	}

	return {init: init};
})(jQuery);

$(document).ready(function(){ giftique.init(); });