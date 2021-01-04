/* $Id$ */
/** 
 * @projectDescription Flotr is a javascript plotting library based on the Prototype Javascript Framework.
 * @author Bas Wenneker
 * @license MIT License <http://www.opensource.org/licenses/mit-license.php>
 * @version 0.2.0
 */
var Flotr = {
	version: '%version%',
	author: 'Bas Wenneker',
	website: 'http://www.solutoire.com',
	/**
	 * An object of the default registered graph types. Use Flotr.register(type, functionName)
	 * to add your own type.
	 */
	_registeredTypes:{
		'lines': 'drawSeriesLines',
		'points': 'drawSeriesPoints',
		'bars': 'drawSeriesBars',
		'candles': 'drawSeriesCandles',
		'pie': 'drawSeriesPie'
	},
	/**
	 * Can be used to register your own chart type. Default types are 'lines', 'points' and 'bars'.
	 * This is still experimental.
	 * @todo Test and confirm.
	 * @param {String} type - type of chart, like 'pies', 'bars' etc.
	 * @param {String} functionName - Name of the draw function, like 'drawSeriesPies', 'drawSeriesBars' etc.
	 */
	register: function(type, functionName){
		Flotr._registeredTypes[type] = functionName+'';	
	},
	/**
	 * Draws the graph. This function is here for backwards compatibility with Flotr version 0.1.0alpha.
	 * You could also draw graphs by directly calling Flotr.Graph(element, data, options).
	 * @param {Element} el - element to insert the graph into
	 * @param {Object} data - an array or object of dataseries
	 * @param {Object} options - an object containing options
	 * @param {Class} _GraphKlass_ - (optional) Class to pass the arguments to, defaults to Flotr.Graph
	 * @return {Object} returns a new graph object and of course draws the graph.
	 */
	draw: function(el, data, options, _GraphKlass_){	
		_GraphKlass_ = _GraphKlass_ || Flotr.Graph;
		return new _GraphKlass_(el, data, options);
	},
	/**
	 * Collects dataseries from input and parses the series into the right format. It returns an Array 
	 * of Objects each having at least the 'data' key set.
	 * @param {Array, Object} data - Object or array of dataseries
	 * @return {Array} Array of Objects parsed into the right format ({(...,) data: [[x1,y1], [x2,y2], ...] (, ...)})
	 */
	getSeries: function(data){
		return data.collect(function(serie){
			var i;
			serie = (serie.data) ? Object.clone(serie) : {'data': serie};
			for (i = serie.data.length-1; i > -1; --i) {
				serie.data[i][1] = (serie.data[i][1] === null ? null : parseFloat(serie.data[i][1])); 
			}
			return serie;
		});
	},
	/**
	 * Recursively merges two objects.
	 * @param {Object} src - source object (likely the object with the least properties)
	 * @param {Object} dest - destination object (optional, object with the most properties)
	 * @return {Object} recursively merged Object
	 */
	merge: function(src, dest){
		var result = dest || {};
		for(var i in src){
			result[i] = (src[i] != null && typeof(src[i]) == 'object' && !(src[i].constructor == Array || src[i].constructor == RegExp) && !Object.isElement(src[i])) ? Flotr.merge(src[i], dest[i]) : result[i] = src[i];		
		}
		return result;
	},	
	/**
	 * Function calculates the ticksize and returns it.
	 * @param {Integer} noTicks - number of ticks
	 * @param {Integer} min - lower bound integer value for the current axis
	 * @param {Integer} max - upper bound integer value for the current axis
	 * @param {Integer} decimals - number of decimals for the ticks
	 * @return {Integer} returns the ticksize in pixels
	 */
	getTickSize: function(noTicks, min, max, decimals){
		var delta = (max - min) / noTicks;	
		var magn = Flotr.getMagnitude(delta);
		
		// Norm is between 1.0 and 10.0.
		var norm = delta / magn;
		
		var tickSize = 10;
		if(norm < 1.5) tickSize = 1;
		else if(norm < 2.25) tickSize = 2;
		else if(norm < 3) tickSize = ((decimals == 0) ? 2 : 2.5);
		else if(norm < 7.5) tickSize = 5;
		
		return tickSize * magn;
	},
	/**
	 * Default tick formatter.
	 * @param {String, Integer} val - tick value integer
	 * @return {String} formatted tick string
	 */
	defaultTickFormatter: function(val){
		return val+'';
	},
	/**
	 * Formats the mouse tracker values.
	 * @param {Object} obj - Track value Object {x:..,y:..}
	 * @return {String} Formatted track string
	 */
	defaultTrackFormatter: function(obj){
		return '('+obj.x+', '+obj.y+')';
	}, 
	/**
	 * Formats the pies labels.
	 * @param {Object} slice - Slice object
	 * @return {String} Formatted pie label string
	 */
	defaultPieLabelFormatter: function(slice) {
		return (slice.fraction*100).toFixed(2)+'%';
	},
	/**
	 * Utility function to convert file size values in bytes to kB, MB, ...
	 * @param value {Number} - The value to convert
	 * @param precision {Number} - The number of digits after the comma (default: 2)
	 * @param base {Number} - The base (default: 1024)
	 */
	convertToBytes: function(value, precision, base){
		var sizes =         ['Y','Z','E','P','T','G','M','k',''],
		    fractionSizes = ['y','z','a','f','p','n','µ','m',''], 
				total = sizes.length;
		    
		base = base || 1024;
		precision = precision || 2;

    if (value == 0) return 0;
		
    if (value > 1) {
			while (total-- && (value > 1)) value /= base;
		}
		else {
			sizes = fractionSizes;
			total = sizes.length;
			while (total-- && (value < 1)) value *= base;
		}
    return (Math.round(value * precision) / precision) + sizes[total];
	},
	/**
	 * Returns the magnitude of the input value.
	 * @param {Integer, Float} x - integer or float value
	 * @return {Integer, Float} returns the magnitude of the input value
	 */
	getMagnitude: function(x){
		return Math.pow(10, Math.floor(Math.log(x) / Math.LN10));
	},
	toPixel: function(val){
		return Math.floor(val)+0.5;//((val-Math.round(val) < 0.4) ? (Math.floor(val)-0.5) : val);
	},
	toRad: function(angle){
		return -angle * (Math.PI/180);
	},
	/**
	 * Parses a color string and returns a corresponding Color.
	 * @param {String, Color} str - string thats representing a color
	 * @return {Color} returns a Color object or false
	 */
	parseColor: function(str){
		if (str instanceof Flotr.Color) return str;
		
		var result, Color = Flotr.Color;

		// rgb(num,num,num)
		if((result = /rgb\(\s*([0-9]{1,3})\s*,\s*([0-9]{1,3})\s*,\s*([0-9]{1,3})\s*\)/.exec(str)))
			return new Color(parseInt(result[1]), parseInt(result[2]), parseInt(result[3]));
	
		// rgba(num,num,num,num)
		if((result = /rgba\(\s*([0-9]{1,3})\s*,\s*([0-9]{1,3})\s*,\s*([0-9]{1,3})\s*,\s*([0-9]+(?:\.[0-9]+)?)\s*\)/.exec(str)))
			return new Color(parseInt(result[1]), parseInt(result[2]), parseInt(result[3]), parseFloat(result[4]));
			
		// rgb(num%,num%,num%)
		if((result = /rgb\(\s*([0-9]+(?:\.[0-9]+)?)\%\s*,\s*([0-9]+(?:\.[0-9]+)?)\%\s*,\s*([0-9]+(?:\.[0-9]+)?)\%\s*\)/.exec(str)))
			return new Color(parseFloat(result[1])*2.55, parseFloat(result[2])*2.55, parseFloat(result[3])*2.55);
	
		// rgba(num%,num%,num%,num)
		if((result = /rgba\(\s*([0-9]+(?:\.[0-9]+)?)\%\s*,\s*([0-9]+(?:\.[0-9]+)?)\%\s*,\s*([0-9]+(?:\.[0-9]+)?)\%\s*,\s*([0-9]+(?:\.[0-9]+)?)\s*\)/.exec(str)))
			return new Color(parseFloat(result[1])*2.55, parseFloat(result[2])*2.55, parseFloat(result[3])*2.55, parseFloat(result[4]));
			
		// #a0b1c2
		if((result = /#([a-fA-F0-9]{2})([a-fA-F0-9]{2})([a-fA-F0-9]{2})/.exec(str)))
			return new Color(parseInt(result[1],16), parseInt(result[2],16), parseInt(result[3],16));
	
		// #fff
		if((result = /#([a-fA-F0-9])([a-fA-F0-9])([a-fA-F0-9])/.exec(str)))
			return new Color(parseInt(result[1]+result[1],16), parseInt(result[2]+result[2],16), parseInt(result[3]+result[3],16));

		// Otherwise, we're most likely dealing with a named color.
		var name = str.strip().toLowerCase();
		if(name == 'transparent'){
			return new Color(255, 255, 255, 0);
		}
		return ((result = Color.lookupColors[name])) ? new Color(result[0], result[1], result[2]) : false;
	},
	/**
	 * Extracts the background-color of the passed element.
	 * @param {Element} element - The element from what the background color is extracted
	 * @return {String} color string
	 */
	extractColor: function(element){
		var color;
		// Loop until we find an element with a background color and stop when we hit the body element. 
		do {
			color = element.getStyle('background-color').toLowerCase();
			if(!(color == '' || color == 'transparent')) break;
			element = element.up(0);
		} while(!element.nodeName.match(/^body$/i));

		// Catch Safari's way of signaling transparent.
		return (color == 'rgba(0, 0, 0, 0)') ? 'transparent' : color;
	}
};
/**
 * Flotr Graph class that plots a graph on creation.
 */
Flotr.Graph = Class.create({
	/**
	 * Flotr Graph constructor.
	 * @param {Element} el - element to insert the graph into
	 * @param {Object} data - an array or object of dataseries
 	 * @param {Object} options - an object containing options
	 */
	initialize: function(el, data, options){
		this.el = $(el);
		
		if (!this.el) throw 'The target container doesn\'t exist';
		
		this.data = data;
		this.series = Flotr.getSeries(data);
		this.setOptions(options);
		
		// Initialize some variables
		this.lastMousePos = { pageX: null, pageY: null };
		this.selection = { first: { x: -1, y: -1}, second: { x: -1, y: -1} };
		this.plotOffset = {left: 0, right: 0, top: 0, bottom: 0};
		this.prevSelection = null;
		this.selectionInterval = null;
		this.ignoreClick = false;   
		this.prevHit = null;
    
		// Create and prepare canvas.
		this.constructCanvas();
		
		// Add event handlers for mouse tracking, clicking and selection
		this.initEvents();
		
		this.findDataRanges();
		this.calculateTicks(this.axes.x);
		this.calculateTicks(this.axes.x2);
		this.calculateTicks(this.axes.y);
		this.calculateTicks(this.axes.y2);
		
		this.calculateSpacing();
		this.draw();
		this.insertLegend();
    
		// Graph and Data tabs
		if (this.options.spreadsheet.show) this.constructTabs();
	},
	/**
	 * Sets options and initializes some variables and color specific values, used by the constructor. 
	 * @param {Object} opts - options object
	 */
	setOptions: function(opts){
		var options = {
			colors: ['#00A8F0', '#C0D800', '#CB4B4B', '#4DA74D', '#9440ED'], //=> The default colorscheme. When there are > 5 series, additional colors are generated.
			title: null,
			subtitle: null,
			legend: {
				show: true,            // => setting to true will show the legend, hide otherwise
				noColumns: 1,          // => number of colums in legend table // @todo: doesn't work for HtmlText = false
				labelFormatter: Prototype.K, // => fn: string -> string
				labelBoxBorderColor: '#CCCCCC', // => border color for the little label boxes
				labelBoxWidth: 14,
				labelBoxHeight: 10,
				labelBoxMargin: 5,
				container: null,       // => container (as jQuery object) to put legend in, null means default on top of graph
				position: 'nw',        // => position of default legend container within plot
				margin: 5,             // => distance from grid edge to default legend container within plot
				backgroundColor: null, // => null means auto-detect
				backgroundOpacity: 0.85// => set to 0 to avoid background, set to 1 for a solid background
			},
			xaxis: {
				ticks: null,           // => format: either [1, 3] or [[1, 'a'], 3]
				showLabels: true,      // => setting to true will show the axis ticks labels, hide otherwise
				labelsAngle: 0,        // => labels' angle, in degrees
				title: null,           // => axis title
				titleAngle: 0,         // => axis title's angle, in degrees
				noTicks: 5,            // => number of ticks for automagically generated ticks
				tickFormatter: Flotr.defaultTickFormatter, // => fn: number -> string
				tickDecimals: null,    // => no. of decimals, null means auto
				min: null,             // => min. value to show, null means set automatically
				max: null,             // => max. value to show, null means set automatically
				autoscaleMargin: 0,    // => margin in % to add if auto-setting min/max
				color: null
			},
			x2axis: {},
			yaxis: {
				ticks: null,           // => format: either [1, 3] or [[1, 'a'], 3]
				showLabels: true,      // => setting to true will show the axis ticks labels, hide otherwise
				labelsAngle: 0,        // => labels' angle, in degrees
				title: null,           // => axis title
				titleAngle: 90,        // => axis title's angle, in degrees
				noTicks: 5,            // => number of ticks for automagically generated ticks
				tickFormatter: Flotr.defaultTickFormatter, // => fn: number -> string
				tickDecimals: null,    // => no. of decimals, null means auto
				min: null,             // => min. value to show, null means set automatically
				max: null,             // => max. value to show, null means set automatically
				autoscaleMargin: 0,    // => margin in % to add if auto-setting min/max
				color: null
			},
			y2axis: {
				titleAngle: 270
			},
			points: {
				show: false,           // => setting to true will show points, false will hide
				radius: 3,             // => point radius (pixels)
				lineWidth: 2,          // => line width in pixels
				fill: true,            // => true to fill the points with a color, false for (transparent) no fill
				fillColor: '#FFFFFF',  // => fill color
				fillOpacity: 0.4
			},
			lines: {
				show: false,           // => setting to true will show lines, false will hide
				lineWidth: 2,          // => line width in pixels
				fill: false,           // => true to fill the area from the line to the x axis, false for (transparent) no fill
				fillColor: null,       // => fill color
				fillOpacity: 0.4       // => opacity of the fill color, set to 1 for a solid fill, 0 hides the fill
			},
			bars: {
				show: false,           // => setting to true will show bars, false will hide
				lineWidth: 2,          // => in pixels
				barWidth: 1,           // => in units of the x axis
				fill: true,            // => true to fill the area from the line to the x axis, false for (transparent) no fill
				fillColor: null,       // => fill color
				fillOpacity: 0.4,      // => opacity of the fill color, set to 1 for a solid fill, 0 hides the fill
				horizontal: false,
				stacked: false,
				centered: true         // => center the bars to their x axis value
			},
			candles: {
				show: false,           // => setting to true will show candle sticks, false will hide
				lineWidth: 1,          // => in pixels
				wickLineWidth: 1,      // => in pixels
				candleWidth: 0.6,      // => in units of the x axis
				fill: true,            // => true to fill the area from the line to the x axis, false for (transparent) no fill
				upFillColor: '#00A8F0',// => up sticks fill color
				downFillColor: '#CB4B4B',// => down sticks fill color
				fillOpacity: 0.5,      // => opacity of the fill color, set to 1 for a solid fill, 0 hides the fill
				barcharts: false       // => draw as barcharts (not standard bars but financial barcharts)
			},
			pie: {
				show: false,           // => setting to true will show bars, false will hide
				lineWidth: 1,          // => in pixels
				fill: true,            // => true to fill the area from the line to the x axis, false for (transparent) no fill
				fillColor: null,       // => fill color
				fillOpacity: 0.6,      // => opacity of the fill color, set to 1 for a solid fill, 0 hides the fill
				explode: 6,            // => the number of pixels the splices will be far from the center
				sizeRatio: 0.6,        // => the size ratio of the pie relative to the plot 
				startAngle: Math.PI/4, // => the first slice start angle
				labelFormatter: Flotr.defaultPieLabelFormatter,
				pie3D: false,          // => whether to draw the pie in 3 dimenstions or not (ineffective) 
				pie3DviewAngle: (Math.PI/2 * 0.8),
				pie3DspliceThickness: 20
			},
			grid: {
				color: '#545454',      // => primary color used for outline and labels
				backgroundColor: null, // => null for transparent, else color
				tickColor: '#DDDDDD',  // => color used for the ticks
				labelMargin: 3,        // => margin in pixels
				verticalLines: true,   // => whether to show gridlines in vertical direction
				horizontalLines: true, // => whether to show gridlines in horizontal direction
				outlineWidth: 2        // => width of the grid outline/border in pixels
			},
			selection: {
				mode: null,            // => one of null, 'x', 'y' or 'xy'
				color: '#B6D9FF',      // => selection box color
				fps: 20                // => frames-per-second
			},
			crosshair: {
				mode: null,            // => one of null, 'x', 'y' or 'xy'
				color: '#FF0000',      // => crosshair color
				hideCursor: true       // => hide the cursor when the crosshair is shown
			},
			mouse: {
				track: false,          // => true to track the mouse, no tracking otherwise
				position: 'se',        // => position of the value box (default south-east)
				relative: false,       // => next to the mouse cursor
				trackFormatter: Flotr.defaultTrackFormatter, // => formats the values in the value box
				margin: 5,             // => margin in pixels of the valuebox
				lineColor: '#FF3F19',  // => line color of points that are drawn when mouse comes near a value of a series
				trackDecimals: 1,      // => decimals for the track values
				sensibility: 2,        // => the lower this number, the more precise you have to aim to show a value
				radius: 3,             // => radius of the track point
 				fillColor: null,       // => color to fill our select bar with only applies to bar and similar graphs (only bars for now)
				fillOpacity: 0.4       // => opacity of the fill color, set to 1 for a solid fill, 0 hides the fill 
			},
			shadowSize: 4,             // => size of the 'fake' shadow
			defaultType: 'lines',      // => default series type
			HtmlText: true,            // => wether to draw the text using HTML or on the canvas
			fontSize: 7.5,             // => canvas' text font size
			spreadsheet: {
				show: false,           // => show the data grid using two tabs
				tabGraphLabel: 'Graph',
				tabDataLabel: 'Data',
				toolbarDownload: 'Download CSV', // @todo: add language support
				toolbarSelectAll: 'Select all'
			}
		};
		
		options.x2axis = Object.extend(Object.clone(options.xaxis), options.x2axis);
		options.y2axis = Object.extend(Object.clone(options.yaxis), options.y2axis);
		this.options = Flotr.merge((opts || {}), options);
		
		// The 4 axes of the plot
		this.axes = {
			x:  {options: this.options.xaxis,  n: 1}, 
			x2: {options: this.options.x2axis, n: 2}, 
			y:  {options: this.options.yaxis,  n: 1}, 
			y2: {options: this.options.y2axis, n: 2}
		};
		
		// Initialize some variables used throughout this function.
		var assignedColors = [],
		    colors = [],
		    ln = this.series.length,
		    neededColors = this.series.length,
		    oc = this.options.colors, 
		    usedColors = [],
		    variation = 0,
		    c, i, j, s, tooClose;

		// Collect user-defined colors from series.
		for(i = neededColors - 1; i > -1; --i){
			c = this.series[i].color;
			if(c != null){
				--neededColors;
				if(Object.isNumber(c)) assignedColors.push(c);
				else usedColors.push(Flotr.parseColor(c));
			}
		}
		
		// Calculate the number of colors that need to be generated.
		for(i = assignedColors.length - 1; i > -1; --i)
			neededColors = Math.max(neededColors, assignedColors[i] + 1);

		// Generate needed number of colors.
		for(i = 0; colors.length < neededColors;){
			c = (oc.length == i) ? new Flotr.Color(100, 100, 100) : Flotr.parseColor(oc[i]);
			
			// Make sure each serie gets a different color.
			var sign = variation % 2 == 1 ? -1 : 1;
			var factor = 1 + sign * Math.ceil(variation / 2) * 0.2;
			c.scale(factor, factor, factor);

			/**
			 * @todo if we're getting too close to something else, we should probably skip this one
			 */
			colors.push(c);
			
			if(++i >= oc.length){
				i = 0;
				++variation;
			}
		}
	
		// Fill the options with the generated colors.
		for(i = 0, j = 0; i < ln; ++i){
			s = this.series[i];

			// Assign the color.
			if(s.color == null){
				s.color = colors[j++].toString();
			}else if(Object.isNumber(s.color)){
				s.color = colors[s.color].toString();
			}
			
			// Every series needs an axis
			if (!s.xaxis) s.xaxis = this.axes.x;
			     if (s.xaxis == 1) s.xaxis = this.axes.x;
			else if (s.xaxis == 2) s.xaxis = this.axes.x2;
			
			if (!s.yaxis) s.yaxis = this.axes.y;
			     if (s.yaxis == 1) s.yaxis = this.axes.y;
			else if (s.yaxis == 2) s.yaxis = this.axes.y2;
			
			// Apply missing options to the series.
			s.lines   = Object.extend(Object.clone(this.options.lines), s.lines);
			s.points  = Object.extend(Object.clone(this.options.points), s.points);
			s.bars    = Object.extend(Object.clone(this.options.bars), s.bars);
			s.candles = Object.extend(Object.clone(this.options.candles), s.candles);
			s.pie     = Object.extend(Object.clone(this.options.pie), s.pie);
			s.mouse   = Object.extend(Object.clone(this.options.mouse), s.mouse);
			
			if(s.shadowSize == null) s.shadowSize = this.options.shadowSize;
		}
	},
	/**
	 * Initializes the canvas and it's overlay canvas element. When the browser is IE, this makes use 
	 * of excanvas. The overlay canvas is inserted for displaying interactions. After the canvas elements
	 * are created, the elements are inserted into the container element.
	 */
	constructCanvas: function(){
		var el = this.el,
			size, c, oc;
		
		// The old canvases are retrieved to avoid memory leaks ...
		this.canvas = el.select('.flotr-canvas')[0];
		this.overlay = el.select('.flotr-overlay')[0];
		
		// ... and all the child elements are removed
		el.childElements().invoke('remove');

		// For positioning labels and overlay.
		el.setStyle({position:'relative', cursor:'default'});

		this.canvasWidth = el.getWidth();
		this.canvasHeight = el.getHeight();
		size = {'width': this.canvasWidth, 'height': this.canvasHeight};

		if(this.canvasWidth <= 0 || this.canvasHeight <= 0){
			throw 'Invalid dimensions for plot, width = ' + this.canvasWidth + ', height = ' + this.canvasHeight;
		}

		// Insert main canvas.
		if (!this.canvas) {
			c = this.canvas = $(document.createElement('canvas'));
			c.className = 'flotr-canvas';
			c.writeAttribute('style', 'position:absolute;left:0px;top:0px;');
		}
		c = this.canvas.writeAttribute(size).show();
		el.insert(c);
    
		// Insert overlay canvas for interactive features.
		if (!this.overlay) {
			oc = this.overlay = $(document.createElement('canvas'));
			oc.className = 'flotr-overlay';
			oc.writeAttribute('style', 'position:absolute;left:0px;top:0px;');
		}
		oc = this.overlay.writeAttribute(size).show();
		el.insert(oc);
		
		if(Prototype.Browser.IE){
			window.G_vmlCanvasManager.initElement(c);
			window.G_vmlCanvasManager.initElement(oc);
		}
		this.ctx = c.getContext('2d');
		this.octx = oc.getContext('2d');

		// Enable text functions
		this.textEnabled = !!this.ctx.drawText;
	},
	/**
	 * Calculates a text box dimensions, wether it is drawn on the canvas or inserted into the DOM
	 * @param {String} text - The text in the box
	 * @param {Object} canvasStyle - An object containing the style for the text if drawn on the canvas
	 * @param {String} HtmlStyle - A CSS style for the text if inserted into the DOM
	 * @param {Object} className - A CSS className for the text if inserted into the DOM
	 */
	getTextDimensions: function(text, canvasStyle, HtmlStyle, className) {
		if (!text) return {width:0, height:0};
		
		if (!this.options.HtmlText && this.textEnabled) {
			var bounds = this.ctx.getTextBounds(text, canvasStyle);
			return {
				width: bounds.width+2, 
				height: bounds.height+6
			};
		}
		else {
			var dummyDiv = this.el.insert('<div style="position:absolute;top:-10000px;'+HtmlStyle+'" class="'+className+' flotr-dummy-div">' + text + '</div>').select(".flotr-dummy-div")[0];
			dim = dummyDiv.getDimensions();
			dummyDiv.remove();
			return dim;
		}
	},
	/**
	 * Builds a matrix of the data to make the correspondance between the x values and the y values :
	 * X value => Y values from the axes
	 * @return {Array} The data grid
	 */
	loadDataGrid: function(){
		if (this.seriesData) return this.seriesData;

		var s = this.series,
		    dg = [];

    /* The data grid is a 2 dimensions array. There is a row for each X value.
     * Each row contains the x value and the corresponding y value for each serie ('undefined' if there isn't one)
    **/
		for(i = 0; i < s.length; ++i){
			s[i].data.each(function(v) {
				var x = v[0],
				    y = v[1], 
					r = dg.find(function(row) {return row[0] == x});
				if (r) r[i+1] = y;
				else {
					var newRow = [];
					newRow[0] = x;
					newRow[i+1] = y;
					dg.push(newRow);
				}
			});
		}
		
    // The data grid is sorted by x value
		dg = dg.sortBy(function(v) {
			return v[0];
		});
		return this.seriesData = dg;
	},
	
	/**
	 * Shows the specified tab, by its name
	 * @todo make a tab manager (Flotr.Tabs)
	 * @param {String} tabName - The tab name
	 */
	showTab: function(tabName){
		var elementsClassNames = 'canvas, .flotr-labels, .flotr-legend, .flotr-legend-bg, .flotr-title, .flotr-subtitle';
		switch(tabName) {
			case 'graph':
				this.datagrid.up().hide();
				this.el.select(elementsClassNames).invoke('show');
				this.tabs.data.removeClassName('selected');
				this.tabs.graph.addClassName('selected');
			break;
			case 'data':
				this.constructDataGrid();
				this.datagrid.up().show();
				this.el.select(elementsClassNames).invoke('hide');
				this.tabs.data.addClassName('selected');
				this.tabs.graph.removeClassName('selected');
			break;
		}
	},
	/**
	 * Builds the tabs in the DOM
	 */
	constructTabs: function(){
		var tabsContainer = new Element('div', {className:'flotr-tabs-group', style:'position:absolute;left:0px;top:'+this.canvasHeight+'px;width:'+this.canvasWidth+'px;'});
		this.el.insert({bottom: tabsContainer});
		this.tabs = {
			graph: new Element('div', {className:'flotr-tab selected', style:'float:left;'}).update(this.options.spreadsheet.tabGraphLabel),
			data: new Element('div', {className:'flotr-tab', style:'float:left;'}).update(this.options.spreadsheet.tabDataLabel)
		};
		
		tabsContainer.insert(this.tabs.graph).insert(this.tabs.data);
		
		this.el.setStyle({height: this.canvasHeight+this.tabs.data.getHeight()+2+'px'});
		
		this.tabs.graph.observe('click', (function() {this.showTab('graph')}).bind(this));
		this.tabs.data.observe('click', (function() {this.showTab('data')}).bind(this));
	},
  /**
   * Constructs the data table for the spreadsheet
   * @todo make a spreadsheet manager (Flotr.Spreadsheet)
   * @return {Element} The resulting table element
   */
	constructDataGrid: function(){
		// If the data grid has already been built, nothing to do here
		if (this.datagrid) return this.datagrid;
		
		var i, j, 
		    s = this.series,
		    datagrid = this.loadDataGrid(),
			t = this.datagrid = new Element('table', {className:'flotr-datagrid', style:'height:100px;'}),
			colgroup = ['<colgroup><col />'];
		
		// First row : series' labels
		var html = ['<tr class="first-row">'];
		html.push('<th>&nbsp;</th>');
		for (i = 0; i < s.length; ++i) {
			html.push('<th scope="col">'+(s[i].label || String.fromCharCode(65+i))+'</th>');
			colgroup.push('<col />');
		}
		html.push('</tr>');
		
		// Data rows
		for (j = 0; j < datagrid.length; ++j) {
			html.push('<tr>');
			for (i = 0; i < s.length+1; ++i) {
				var tag = 'td';
				var content = (datagrid[j][i] != null ? Math.round(datagrid[j][i]*100000)/100000 : '');
				
				if (i == 0) {
					tag = 'th';
					var label;
					if(this.options.xaxis.ticks) {
						var tick = this.options.xaxis.ticks.find(function (x) { return x[0] == datagrid[j][i] });
						if (tick) label = tick[1];
					} 
					else {
						label = this.options.xaxis.tickFormatter(content);
					}
					
					if (label) content = label;
				}

				html.push('<'+tag+(tag=='th'?' scope="row"':'')+'>'+content+'</'+tag+'>');
			}
			html.push('</tr>');
		}
		colgroup.push('</colgroup>');
		t.update(colgroup.join('')+html.join(''));
		
		if (!Prototype.Browser.IE) {
			t.select('td').each(function(td) {
				td.observe('mouseover', function(e){
					td = e.element();
					var siblings = td.previousSiblings();
					
					t.select('th[scope=col]')[siblings.length-1].addClassName('hover');
					t.select('colgroup col')[siblings.length].addClassName('hover');
				});
				
				td.observe('mouseout', function(){
					t.select('colgroup col.hover, th.hover').each(function(e){e.removeClassName('hover')});
				});
			});
		}
		
		var toolbar = new Element('div', {className: 'flotr-datagrid-toolbar'}).
			insert(new Element('button', {type:'button', className:'flotr-datagrid-toolbar-button'}).update(this.options.spreadsheet.toolbarDownload).observe('click', this.downloadCSV.bind(this))).
			insert(new Element('button', {type:'button', className:'flotr-datagrid-toolbar-button'}).update(this.options.spreadsheet.toolbarSelectAll).observe('click', this.selectAllData.bind(this)));
		
		var container = new Element('div', {className:'flotr-datagrid-container', style:'left:0px;top:0px;width:'+this.canvasWidth+'px;height:'+this.canvasHeight+'px;overflow:auto;'});
		container.insert(toolbar);
		t.wrap(container.hide());
		
		this.el.insert(container);
		return t;
	},
	/**
	 * Selects the data table in the DOM for copy/paste
	 */
	selectAllData: function(){
		if (this.tabs) {
			var selection, range, doc, win, node = this.constructDataGrid();

			this.showTab('data');
			
			// deferred to be able to select the table
			(function () {
				if ((doc = node.ownerDocument) && (win = doc.defaultView) && 
				    win.getSelection && doc.createRange && 
				    (selection = window.getSelection()) && 
				    selection.removeAllRanges) {
						range = doc.createRange();
						range.selectNode(node);
						selection.removeAllRanges();
						selection.addRange(range);
				}
				else if (document.body && document.body.createTextRange && 
				        (range = document.body.createTextRange())) {
						range.moveToElementText(node);
						range.select();
				}
			}).defer();
			return true;
		}
		else return false;
	},
	/**
	 * Converts the data into CSV in order to download a file
	 */
	downloadCSV: function(){
		var i, csv = '"x"',
		    series = this.series,
		    dg = this.loadDataGrid();
		
		for (i = 0; i < series.length; ++i) {
			csv += '%09"'+(series[i].label || String.fromCharCode(65+i))+'"'; // \t
		}
		csv += "%0D%0A"; // \r\n
		
		for (i = 0; i < dg.length; ++i) {
			if (this.options.xaxis.ticks) {
				var tick = this.options.xaxis.ticks.find(function (x) { return x[0] == dg[i][0] });
				if (tick) dg[i][0] = tick[1];
			}
			else {
				dg[i][0] = this.options.xaxis.tickFormatter(dg[i][0]);
			}
			csv += dg[i].join('%09')+"%0D%0A"; // \t and \r\n
		}
		if (Prototype.Browser.IE) {
			csv = csv.gsub('%09', '\t').gsub('%0A', '\n').gsub('%0D', '\r');
			window.open().document.write(csv);
		}
		else window.open('data:text/csv,'+csv);
	},
	/**
	 * Initializes event some handlers.
	 */
	initEvents: function () {
		//@todo: maybe stopObserving with only flotr functions
		this.overlay.stopObserving();
		this.overlay.observe('mousedown', this.mouseDownHandler.bind(this));
		this.overlay.observe('mousemove', this.mouseMoveHandler.bind(this));
		this.overlay.observe('click', this.clickHandler.bind(this));
	},
	/**
	 * Function determines the min and max values for the xaxis and yaxis.
	 */
	findDataRanges: function(){
		var s = this.series, 
		    a = this.axes;
		
		a.x.datamin  = a.x.datamax = 
		a.x2.datamin = a.x2.datamax = 
		a.y.datamin  = a.y.datamax = 
		a.y2.datamin = a.y2.datamax = 0;
		
		if(s.length > 0){
			var i, j, h, x, y, data, xaxis, yaxis;
		
			// Get datamin, datamax start values 
			for(i = 0; i < s.length; ++i) {
				data = s[i].data, 
				xaxis = s[i].xaxis, 
				yaxis = s[i].yaxis;
				
				if (data.length > 0 && !s[i].hide) {
					if (!xaxis.used) xaxis.datamin = xaxis.datamax = data[0][0];
					if (!yaxis.used) yaxis.datamin = yaxis.datamax = data[0][1];
					xaxis.used = true;
					yaxis.used = true;

					for(h = data.length - 1; h > -1; --h){
	  					x = data[h][0];
	  			         if(x < xaxis.datamin) xaxis.datamin = x;
	   					else if(x > xaxis.datamax) xaxis.datamax = x;
	  			    
	  					for(j = 1; j < data[h].length; j++){
	  						y = data[h][j];
	  				         if(y < yaxis.datamin) yaxis.datamin = y;
	  	  				else if(y > yaxis.datamax) yaxis.datamax = y;
	  					}
					}
				}
			}
		}
		
		this.findXAxesValues();
		
		this.calculateRange(a.x);
		this.extendXRangeIfNeededByBar(a.x);
		
		if (a.x2.used) {
			this.calculateRange(a.x2);
			this.extendXRangeIfNeededByBar(a.x2);
		}
		
		this.calculateRange(a.y);
		this.extendYRangeIfNeededByBar(a.y);
		
		if (a.y2.used) {
			this.calculateRange(a.y2);
			this.extendYRangeIfNeededByBar(a.y2);
		}
	},
	/**
	 * Calculates the range of an axis to apply autoscaling.
	 * @param {Object} axis - The axis for what the range will be calculated
	 */
	calculateRange: function(axis){
		var o = axis.options,
		    min = o.min != null ? o.min : axis.datamin,
		    max = o.max != null ? o.max : axis.datamax,
		    margin;

		if(max - min == 0.0){
			var widen = (max == 0.0) ? 1.0 : 0.01;
			min -= widen;
			max += widen;
		}
		axis.tickSize = Flotr.getTickSize(o.noTicks, min, max, o.tickDecimals);

		// Autoscaling.
		if(o.min == null){
			// Add a margin.
			margin = o.autoscaleMargin;
			if(margin != 0){
				min -= axis.tickSize * margin;
				
				// Make sure we don't go below zero if all values are positive.
				if(min < 0 && axis.datamin >= 0) min = 0;
				min = axis.tickSize * Math.floor(min / axis.tickSize);
			}
		}
		if(o.max == null){
			margin = o.autoscaleMargin;
			if(margin != 0){
				max += axis.tickSize * margin;
				if(max > 0 && axis.datamax <= 0) max = 0;				
				max = axis.tickSize * Math.ceil(max / axis.tickSize);
			}
		}
		axis.min = min;
		axis.max = max;
	},
	/**
	 * Bar series autoscaling in x direction.
	 * @param {Object} axis - The axis to extend if needed
	 */
	extendXRangeIfNeededByBar: function(axis){
		if(axis.options.max == null){
			var newmin = axis.min,
			    newmax = axis.max,
			    i, s, b, c,
			    stackedSums = [], 
			    lastSerie = null;

			for(i = 0; i < this.series.length; ++i){
				s = this.series[i];
				b = s.bars;
				c = s.candles;
				if(s.xaxis == axis) {
					// For candle sticks and centered bars
					if (c.show || (b.centered && b.show)) {
						// We don't use c.candleWidth in order not to stick the borders
						newmax = Math.max(axis.datamax + 0.5, newmax);
						newmin = Math.min(axis.datamin - 0.5, newmin);
					}
					
					if (b.show) {
						// For normal vertical bars
						if (!b.horizontal && (b.barWidth + axis.datamax > newmax))
							newmax = axis.max + (b.centered ? b.barWidth/2 : b.barWidth);

						// For horizontal stacked bars
						if(b.stacked && b.horizontal){
							for (j = 0; j < s.data.length; j++) {
								if (b.show && b.stacked) {
									var x = s.data[j][0]+'';
									stackedSums[x] = (stackedSums[x] || 0) + s.data[j][1];
									lastSerie = s;
								}
							}
					    
							for (var j in stackedSums) {
								newmax = Math.max(stackedSums[j], newmax);
							}
						}
					}
				}
			}
			axis.lastSerie = lastSerie;
			axis.max = newmax;
			axis.min = newmin;
		}
	},
	/**
	 * Bar series autoscaling in y direction.
	 * @param {Object} axis - The axis to extend if needed
	 */
	extendYRangeIfNeededByBar: function(axis){
		if(axis.options.max == null){
			var newmax = axis.max,
				  i, s, b, c,
				  stackedSums = {},
				  lastSerie = null;
									
			for(i = 0; i < this.series.length; ++i){
				s = this.series[i];
				b = s.bars;
				c = s.candles;
				if (s.yaxis == axis && b.show && !s.hide) {
					// For normal horizontal bars and candle sticks
					if (b.horizontal && (b.barWidth + axis.datamax > newmax) || (c.candleWidth + axis.datamax > newmax)){
						newmax = axis.max + b.barWidth;
					}
					
					// For vertical stacked bars
					if(b.stacked && !b.horizontal){
						for (j = 0; j < s.data.length; j++) {
							if (s.bars.show && s.bars.stacked) {
								var x = s.data[j][0]+'';
								stackedSums[x] = (stackedSums[x] || 0) + s.data[j][1];
								lastSerie = s;
							}
						}
						
						for (var j in stackedSums) {
							newmax = Math.max(stackedSums[j], newmax);
						}
					}
				}
			}
			axis.lastSerie = lastSerie;
			axis.max = newmax;
		}
	},
	/** 
	 * Find every values of the x axes
	 */
	findXAxesValues: function(){
		for(i = this.series.length-1; i > -1 ; --i){
			s = this.series[i];
			s.xaxis.values = s.xaxis.values || {};
			for (j = s.data.length-1; j > -1 ; --j){
				s.xaxis.values[s.data[j][0]+''] = {};
			}
		}
	},
	/**
	 * Calculate axis ticks.
	 * @param {Object} axis - The axis for what the ticks will be calculated
	 */
	calculateTicks: function(axis){
		var o = axis.options, i, v;
		
		axis.ticks = [];	
		if(o.ticks){
			var ticks = o.ticks, t, label;

			if(Object.isFunction(ticks)){
				ticks = ticks({min: axis.min, max: axis.max});
			}
			
			// Clean up the user-supplied ticks, copy them over.
			for(i = 0; i < ticks.length; ++i){
				t = ticks[i];
				if(typeof(t) == 'object'){
					v = t[0];
					label = (t.length > 1) ? t[1] : o.tickFormatter(v);
				}else{
					v = t;
					label = o.tickFormatter(v);
				}
				axis.ticks[i] = { v: v, label: label };
			}
		}
		else {
			// Round to nearest multiple of tick size.
			var start = axis.tickSize * Math.ceil(axis.min / axis.tickSize),
			    decimals;
			
			// Then store all possible ticks.
			for(i = 0; start + i * axis.tickSize <= axis.max; ++i){
				v = start + i * axis.tickSize;
				
				// Round (this is always needed to fix numerical instability).
				decimals = o.tickDecimals;
				if(decimals == null) decimals = 1 - Math.floor(Math.log(axis.tickSize) / Math.LN10);
				if(decimals < 0) decimals = 0;
				
				v = v.toFixed(decimals);
				axis.ticks.push({ v: v, label: o.tickFormatter(v) });
			}
		}
	},
	/**
	 * Calculates axis label sizes.
	 */
	calculateSpacing: function(){
		var a = this.axes,
  			options = this.options,
  			series = this.series,
  			margin = options.grid.labelMargin,
  			x = a.x,
  			x2 = a.x2,
  			y = a.y,
  			y2 = a.y2,
  			maxOutset = 2,
  			i, j, l, dim;
		
		// Labels width and height
		[x, x2, y, y2].each(function(axis) {
			var maxLabel = '';
			
			if (axis.options.showLabels) {
				for(i = 0; i < axis.ticks.length; ++i){
					l = axis.ticks[i].label.length;
					if(l > maxLabel.length){
						maxLabel = axis.ticks[i].label;
					}
				}
			}
			axis.maxLabel  = this.getTextDimensions(maxLabel, {size:options.fontSize, angle: Flotr.toRad(axis.options.labelsAngle)}, 'font-size:smaller;', 'flotr-grid-label');
			axis.titleSize = this.getTextDimensions(axis.options.title, {size: options.fontSize*1.2, angle: Flotr.toRad(axis.options.titleAngle)}, 'font-weight:bold;', 'flotr-axis-title');
		}, this);

		// Title height
		dim = this.getTextDimensions(options.title, {size: options.fontSize*1.5}, 'font-size:1em;font-weight:bold;', 'flotr-title');
		this.titleHeight = dim.height;

		// Subtitle height
		dim = this.getTextDimensions(options.subtitle, {size: options.fontSize}, 'font-size:smaller;', 'flotr-subtitle');
		this.subtitleHeight = dim.height;

		// Grid outline line width.
		if(options.show){
			maxOutset = Math.max(maxOutset, options.points.radius + options.points.lineWidth/2);
		}
		for(j = 0; j < options.length; ++j){
			if (series[j].points.show){
				maxOutset = Math.max(maxOutset, series[j].points.radius + series[j].points.lineWidth/2);
			}
		}
		
		var p = this.plotOffset;
		p.bottom += (x.options.showLabels ?  (x.maxLabel.height  + margin) : 0) + 
		            (x.options.title ?       (x.titleSize.height + margin) : 0) + maxOutset;
		
		p.top    += (x2.options.showLabels ? (x2.maxLabel.height  + margin) : 0) + 
		            (x2.options.title ?      (x2.titleSize.height + margin) : 0) + this.subtitleHeight + this.titleHeight + maxOutset;
    
		p.left   += (y.options.showLabels ?  (y.maxLabel.width  + margin) : 0) + 
		            (y.options.title ?       (y.titleSize.width + margin) : 0) + maxOutset;
		
		p.right  += (y2.options.showLabels ? (y2.maxLabel.width  + margin) : 0) + 
		            (y2.options.title ?      (y2.titleSize.width + margin) : 0) + maxOutset;
    
		p.top = Math.floor(p.top); // In order the outline not to be blured
    
		this.plotWidth  = this.canvasWidth - p.left - p.right;
		this.plotHeight = this.canvasHeight - p.bottom - p.top;
		
		x.scale  = this.plotWidth / (x.max - x.min);
		x2.scale = this.plotWidth / (x2.max - x2.min);
		y.scale  = this.plotHeight / (y.max - y.min);
		y2.scale = this.plotHeight / (y2.max - y2.min);
	},
	/**
	 * Draws grid, labels and series.
	 */
	draw: function() {
		this.drawGrid();
		this.drawLabels();
		this.drawTitles();
    
		if(this.series.length){
			this.el.fire('flotr:beforedraw', [this.series, this]);
			for(var i = 0; i < this.series.length; i++){
				if (!this.series[i].hide)
					this.drawSeries(this.series[i]);
			}
		}
		this.el.fire('flotr:afterdraw', [this.series, this]);
	},
	/**
	 * Translates absolute horizontal x coordinates to relative coordinates.
	 * @param {Integer} x - absolute integer x coordinate
	 * @param {Object} axis - the reference axis
	 * @return {Integer} translated relative x coordinate
	 */
	tHoz: function(x, axis){
		axis = axis || this.axes.x;
		return (x - axis.min) * axis.scale;
	},
	/**
	 * Translates absolute vertical x coordinates to relative coordinates.
	 * @param {Integer} y - absolute integer y coordinate
	 * @param {Object} axis - the reference axis
	 * @return {Integer} translated relative y coordinate
	 */
	tVert: function(y, axis){
		axis = axis || this.axes.y;
		return this.plotHeight - (y - axis.min) * axis.scale;
	},
	/**
	 * Draws a grid for the graph.
	 */
	drawGrid: function(){
		var v, o = this.options,
		    ctx = this.ctx;
		if(o.grid.verticalLines || o.grid.horizontalLines){
			this.el.fire('flotr:beforegrid', [this.axes.x, this.axes.y, o, this]);
		}
		ctx.save();
		ctx.translate(this.plotOffset.left, this.plotOffset.top);

		// Draw grid background, if present in options.
		if(o.grid.backgroundColor != null){
			ctx.fillStyle = o.grid.backgroundColor;
			ctx.fillRect(0, 0, this.plotWidth, this.plotHeight);
		}
		
		// Draw grid lines in vertical direction.
		ctx.lineWidth = 1;
		ctx.strokeStyle = o.grid.tickColor;
		ctx.beginPath();
		if(o.grid.verticalLines){
			for(var i = 0; i < this.axes.x.ticks.length; ++i){
				v = this.axes.x.ticks[i].v;
				// Don't show lines on upper and lower bounds.
				if ((v == this.axes.x.min || v == this.axes.x.max) && o.grid.outlineWidth != 0)
					continue;
	
				ctx.moveTo(Math.floor(this.tHoz(v)) + ctx.lineWidth/2, 0);
				ctx.lineTo(Math.floor(this.tHoz(v)) + ctx.lineWidth/2, this.plotHeight);
			}
		}
		
		// Draw grid lines in horizontal direction.
		if(o.grid.horizontalLines){
			for(var j = 0; j < this.axes.y.ticks.length; ++j){
				v = this.axes.y.ticks[j].v;
				// Don't show lines on upper and lower bounds.
				if ((v == this.axes.y.min || v == this.axes.y.max) && o.grid.outlineWidth != 0)
					continue;
	
				ctx.moveTo(0, Math.floor(this.tVert(v)) + ctx.lineWidth/2);
				ctx.lineTo(this.plotWidth, Math.floor(this.tVert(v)) + ctx.lineWidth/2);
			}
		}
		ctx.stroke();
		
		// Draw axis/grid border.
		if(o.grid.outlineWidth != 0) {
			ctx.lineWidth = o.grid.outlineWidth;
			ctx.strokeStyle = o.grid.color;
			ctx.lineJoin = 'round';
			ctx.strokeRect(0, 0, this.plotWidth, this.plotHeight);
		}
		ctx.restore();
		if(o.grid.verticalLines || o.grid.horizontalLines){
			this.el.fire('flotr:aftergrid', [this.axes.x, this.axes.y, o, this]);
		}
	},
	/**
	 * Draws labels for x and y axis.
	 */   
	drawLabels: function(){		
		// Construct fixed width label boxes, which can be styled easily. 
		var noLabels = 0, axis,
			xBoxWidth, i, html, tick,
			options = this.options,
		    ctx = this.ctx,
		    a = this.axes;
		
		for(i = 0; i < a.x.ticks.length; ++i){
			if (a.x.ticks[i].label) {
				++noLabels;
			}
		}
		xBoxWidth = this.plotWidth / noLabels;
    
		if (!options.HtmlText && this.textEnabled) {
			var style = {
				size: options.fontSize,
				adjustAlign: true
			};
	
			// Add x labels.
			axis = a.x;
			style.color = axis.options.color || options.grid.color;
			for(i = 0; i < axis.ticks.length && axis.options.showLabels && axis.used; ++i){
				tick = axis.ticks[i];
				if(!tick.label || tick.label.length == 0) continue;
				
				style.angle = Flotr.toRad(axis.options.labelsAngle);
				style.halign = 'c';
				style.valign = 't';
				
				ctx.drawText(
					tick.label,
					this.plotOffset.left + this.tHoz(tick.v, axis), 
					this.plotOffset.top + this.plotHeight + options.grid.labelMargin,
					style
				);
			}
			  
			// Add x2 labels.
			axis = a.x2;
			style.color = axis.options.color || options.grid.color;
			for(i = 0; i < axis.ticks.length && axis.options.showLabels && axis.used; ++i){
				tick = axis.ticks[i];
				if(!tick.label || tick.label.length == 0) continue;
				
				style.angle = Flotr.toRad(axis.options.labelsAngle);
				style.halign = 'c';
				style.valign = 'b';
				
				ctx.drawText(
					tick.label,
					this.plotOffset.left + this.tHoz(tick.v, axis), 
					this.plotOffset.top + options.grid.labelMargin,
					style
				);
			}
			  
			// Add y labels.
			axis = a.y;
			style.color = axis.options.color || options.grid.color;
			for(i = 0; i < axis.ticks.length && axis.options.showLabels && axis.used; ++i){
				tick = axis.ticks[i];
				if (!tick.label || tick.label.length == 0) continue;
				
				style.angle = Flotr.toRad(axis.options.labelsAngle);
				style.halign = 'r';
				style.valign = 'm';
				
				ctx.drawText(
					tick.label,
					this.plotOffset.left - options.grid.labelMargin, 
					this.plotOffset.top + this.tVert(tick.v, axis),
					style
				);
			}
			  
			// Add y2 labels.
			axis = a.y2;
			style.color = axis.options.color || options.grid.color;
			for(i = 0; i < axis.ticks.length && axis.options.showLabels && axis.used; ++i){
				tick = axis.ticks[i];
				if (!tick.label || tick.label.length == 0) continue;
				
				style.angle = Flotr.toRad(axis.options.labelsAngle);
				style.halign = 'l';
				style.valign = 'm';
				
				ctx.drawText(
					tick.label,
					this.plotOffset.left + this.plotWidth + options.grid.labelMargin, 
					this.plotOffset.top + this.tVert(tick.v, axis),
					style
				);
				
				ctx.save();
				ctx.strokeStyle = style.color;
				ctx.beginPath();
				ctx.moveTo(this.plotOffset.left + this.plotWidth - 8, this.plotOffset.top + this.tVert(tick.v, axis));
				ctx.lineTo(this.plotOffset.left + this.plotWidth,     this.plotOffset.top + this.tVert(tick.v, axis));
				ctx.stroke();
				ctx.restore();
			}
		} 
		else if (a.x.options.showLabels || 
		         a.x2.options.showLabels || 
		         a.y.options.showLabels || 
		         a.y2.options.showLabels) {
			html = ['<div style="font-size:smaller;color:' + options.grid.color + ';" class="flotr-labels">'];
			
			// Add x labels.
			axis = a.x;
			if (axis.options.showLabels){
				for(i = 0; i < axis.ticks.length; ++i){
					tick = axis.ticks[i];
					if(!tick.label || tick.label.length == 0 || 
					    (this.plotOffset.left + this.tHoz(tick.v, axis) < 0) || 
					    (this.plotOffset.left + this.tHoz(tick.v, axis) > this.canvasWidth)) continue;
					html.push('<div style="position:absolute;top:' + (this.plotOffset.top + this.plotHeight + options.grid.labelMargin) + 'px;left:' + (this.plotOffset.left + this.tHoz(tick.v, axis) - xBoxWidth/2) + 'px;width:' + xBoxWidth + 'px;text-align:center;'+(axis.options.color?('color:'+axis.options.color+';'):'')+'" class="flotr-grid-label">' + tick.label + '</div>');
				}
			}
			
			// Add x2 labels.
			axis = a.x2;
			if (axis.options.showLabels && axis.used){
				for(i = 0; i < axis.ticks.length; ++i){
					tick = axis.ticks[i];
					if(!tick.label || tick.label.length == 0 || 
					    (this.plotOffset.left + this.tHoz(tick.v, axis) < 0) || 
					    (this.plotOffset.left + this.tHoz(tick.v, axis) > this.canvasWidth)) continue;
					html.push('<div style="position:absolute;top:' + (this.plotOffset.top - options.grid.labelMargin - axis.maxLabel.height) + 'px;left:' + (this.plotOffset.left + this.tHoz(tick.v, axis) - xBoxWidth/2) + 'px;width:' + xBoxWidth + 'px;text-align:center;'+(axis.options.color?('color:'+axis.options.color+';'):'')+'" class="flotr-grid-label">' + tick.label + '</div>');
				}
			}
			
			// Add y labels.
			axis = a.y;
			if (axis.options.showLabels){
				for(i = 0; i < axis.ticks.length; ++i){
					tick = axis.ticks[i];
					if (!tick.label || tick.label.length == 0 ||
							 (this.plotOffset.top + this.tVert(tick.v, axis) < 0) || 
							 (this.plotOffset.top + this.tVert(tick.v, axis) > this.canvasHeight)) continue;
					html.push('<div style="position:absolute;top:' + (this.plotOffset.top + this.tVert(tick.v, axis) - axis.maxLabel.height/2) + 'px;left:0;width:' + (this.plotOffset.left - options.grid.labelMargin) + 'px;text-align:right;'+(axis.options.color?('color:'+axis.options.color+';'):'')+'" class="flotr-grid-label">' + tick.label + '</div>');
				}
			}
			
			// Add y2 labels.
			axis = a.y2;
			if (axis.options.showLabels && axis.used){
				ctx.save();
				ctx.strokeStyle = axis.options.color || options.grid.color;
				ctx.beginPath();
				
				for(i = 0; i < axis.ticks.length; ++i){
					tick = axis.ticks[i];
					if (!tick.label || tick.label.length == 0 ||
							 (this.plotOffset.top + this.tVert(tick.v, axis) < 0) || 
							 (this.plotOffset.top + this.tVert(tick.v, axis) > this.canvasHeight)) continue;
					html.push('<div style="position:absolute;top:' + (this.plotOffset.top + this.tVert(tick.v, axis) - axis.maxLabel.height/2) + 'px;right:0;width:' + (this.plotOffset.right - options.grid.labelMargin) + 'px;text-align:left;'+(axis.options.color?('color:'+axis.options.color+';'):'')+'" class="flotr-grid-label">' + tick.label + '</div>');

					ctx.moveTo(this.plotOffset.left + this.plotWidth - 8, this.plotOffset.top + this.tVert(tick.v, axis));
					ctx.lineTo(this.plotOffset.left + this.plotWidth,     this.plotOffset.top + this.tVert(tick.v, axis));
				}
				ctx.stroke();
				ctx.restore();
			}
			
			html.push('</div>');
			this.el.insert(html.join(''));
		}
	},
	/**
	 * Draws the title and the subtitle
	 */
	drawTitles: function(){
		var html,
		    options = this.options,
		    margin = options.grid.labelMargin,
		    ctx = this.ctx,
		    a = this.axes;
		
		if (!options.HtmlText && this.textEnabled) {
			var style = {
				size: options.fontSize,
				color: options.grid.color,
				halign: 'c'
			};
			
			// Add subtitle
			if (options.subtitle){
				ctx.drawText(
					options.subtitle,
					this.plotOffset.left + this.plotWidth/2, 
					this.titleHeight + this.subtitleHeight - 2,
					style
				);
			}
			
			style.weight = 1.5;
			style.size *= 1.5;
			
			// Add title
			if (options.title){
				ctx.drawText(
					options.title,
					this.plotOffset.left + this.plotWidth/2, 
					this.titleHeight - 2,
					style
				);
			}
			
			style.weight = 1.8;
			style.size *= 0.8;
			style.adjustAlign = true;
			
			// Add x axis title
			if (a.x.options.title && a.x.used){
				style.halign = 'c';
				style.valign = 't';
				style.angle = Flotr.toRad(a.x.options.titleAngle);
				ctx.drawText(
					a.x.options.title,
					this.plotOffset.left + this.plotWidth/2, 
					this.plotOffset.top + a.x.maxLabel.height + this.plotHeight + 2 * margin,
					style
				);
			}
			
			// Add x2 axis title
			if (a.x2.options.title && a.x2.used){
				style.halign = 'c';
				style.valign = 'b';
				style.angle = Flotr.toRad(a.x2.options.titleAngle);
				ctx.drawText(
					a.x2.options.title,
					this.plotOffset.left + this.plotWidth/2, 
					this.plotOffset.top - a.x2.maxLabel.height - 2 * margin,
					style
				);
			}
			
			// Add y axis title
			if (a.y.options.title && a.y.used){
				style.halign = 'r';
				style.valign = 'm';
				style.angle = Flotr.toRad(a.y.options.titleAngle);
				ctx.drawText(
					a.y.options.title,
					this.plotOffset.left - a.y.maxLabel.width - 2 * margin, 
					this.plotOffset.top + this.plotHeight / 2,
					style
				);
			}
			
			// Add y2 axis title
			if (a.y2.options.title && a.y2.used){
				style.halign = 'l';
				style.valign = 'm';
				style.angle = Flotr.toRad(a.y2.options.titleAngle);
				ctx.drawText(
					a.y2.options.title,
					this.plotOffset.left + this.plotWidth + a.y2.maxLabel.width + 2 * margin, 
					this.plotOffset.top + this.plotHeight / 2,
					style
				);
			}
		} 
		else {
			html = ['<div style="color:'+options.grid.color+';" class="flotr-titles">'];
			
			// Add title
			if (options.title)
				html.push('<div style="position:absolute;top:0;left:'+this.plotOffset.left+'px;font-size:1em;font-weight:bold;text-align:center;width:'+this.plotWidth+'px;" class="flotr-title">'+options.title+'</div>');
			
			// Add subtitle
			if (options.subtitle)
				html.push('<div style="position:absolute;top:'+this.titleHeight+'px;left:'+this.plotOffset.left+'px;font-size:smaller;text-align:center;width:'+this.plotWidth+'px;" class="flotr-subtitle">'+options.subtitle+'</div>');

			html.push('</div>');
			
			html.push('<div class="flotr-axis-title" style="font-weight:bold;">');
			
			// Add x axis title
			if (a.x.options.title && a.x.used)
				html.push('<div style="position:absolute;top:' + (this.plotOffset.top + this.plotHeight + options.grid.labelMargin + a.x.titleSize.height) + 'px;left:' + this.plotOffset.left + 'px;width:' + this.plotWidth + 'px;text-align:center;" class="flotr-axis-title">' + a.x.options.title + '</div>');
			
			// Add x2 axis title
			if (a.x2.options.title && a.x2.used)
				html.push('<div style="position:absolute;top:0;left:' + this.plotOffset.left + 'px;width:' + this.plotWidth + 'px;text-align:center;" class="flotr-axis-title">' + a.x2.options.title + '</div>');
			
			// Add y axis title
			if (a.y.options.title && a.y.used)
				html.push('<div style="position:absolute;top:' + (this.plotOffset.top + this.plotHeight/2 - a.y.titleSize.height/2) + 'px;left:0;text-align:right;" class="flotr-axis-title">' + a.y.options.title + '</div>');
			
			// Add y2 axis title
			if (a.y2.options.title && a.y2.used)
				html.push('<div style="position:absolute;top:' + (this.plotOffset.top + this.plotHeight/2 - a.y.titleSize.height/2) + 'px;right:0;text-align:right;" class="flotr-axis-title">' + a.y2.options.title + '</div>');
			
			html.push('</div>');
			
			this.el.insert(html.join(''));
		}
	},
	/**
	 * Actually draws the graph.
	 * @param {Object} series - series to draw
	 */
	drawSeries: function(series){
		series = series || this.series;
		
		var drawn = false;
		for(var type in Flotr._registeredTypes){
			if(series[type] && series[type].show){
				this[Flotr._registeredTypes[type]](series);
				drawn = true;
			}
		}
		
		if(!drawn){
			this[Flotr._registeredTypes[this.options.defaultType]](series);
		}
	},
	
	plotLine: function(series, offset){
		var ctx = this.ctx,
		    xa = series.xaxis,
		    ya = series.yaxis,
  			tHoz = this.tHoz.bind(this),
  			tVert = this.tVert.bind(this),
  			data = series.data;
			
		if(data.length < 2) return;

		var prevx = tHoz(data[0][0], xa),
		    prevy = tVert(data[0][1], ya) + offset;

		ctx.beginPath();
		ctx.moveTo(prevx, prevy);
		for(var i = 0; i < data.length - 1; ++i){
			var x1 = data[i][0],   y1 = data[i][1],
			    x2 = data[i+1][0], y2 = data[i+1][1];

			// To allow empty values
			if (y1 === null || y2 === null) continue;
      
			/**
			 * Clip with ymin.
			 */
			if(y1 <= y2 && y1 < ya.min){
				/**
				 * Line segment is outside the drawing area.
				 */
				if(y2 < ya.min) continue;
				
				/**
				 * Compute new intersection point.
				 */
				x1 = (ya.min - y1) / (y2 - y1) * (x2 - x1) + x1;
				y1 = ya.min;
			}
			else if(y2 <= y1 && y2 < ya.min){
				if(y1 < ya.min) continue;
				x2 = (ya.min - y1) / (y2 - y1) * (x2 - x1) + x1;
				y2 = ya.min;
			}

			/**
			 * Clip with ymax.
			 */ 
			if(y1 >= y2 && y1 > ya.max) {
				if(y2 > ya.max) continue;
				x1 = (ya.max - y1) / (y2 - y1) * (x2 - x1) + x1;
				y1 = ya.max;
			}
			else if(y2 >= y1 && y2 > ya.max){
				if(y1 > ya.max) continue;
				x2 = (ya.max - y1) / (y2 - y1) * (x2 - x1) + x1;
				y2 = ya.max;
			}

			/**
			 * Clip with xmin.
			 */
			if(x1 <= x2 && x1 < xa.min){
				if(x2 < xa.min) continue;
				y1 = (xa.min - x1) / (x2 - x1) * (y2 - y1) + y1;
				x1 = xa.min;
			}
			else if(x2 <= x1 && x2 < xa.min){
				if(x1 < xa.min) continue;
				y2 = (xa.min - x1) / (x2 - x1) * (y2 - y1) + y1;
				x2 = xa.min;
			}

			/**
			 * Clip with xmax.
			 */
			if(x1 >= x2 && x1 > xa.max){
				if (x2 > xa.max) continue;
				y1 = (xa.max - x1) / (x2 - x1) * (y2 - y1) + y1;
				x1 = xa.max;
			}
			else if(x2 >= x1 && x2 > xa.max){
				if(x1 > xa.max) continue;
				y2 = (xa.max - x1) / (x2 - x1) * (y2 - y1) + y1;
				x2 = xa.max;
			}

			if(prevx != tHoz(x1, xa) || prevy != tVert(y1, ya) + offset)
				ctx.moveTo(tHoz(x1, xa), tVert(y1, ya) + offset);
			
			prevx = tHoz(x2, xa);
			prevy = tVert(y2, ya) + offset;
			ctx.lineTo(prevx, prevy);
		}
		ctx.stroke();
	},
	/**
	 * Function used to fill
	 * @param {Object} series - The series to draw
	 * @param {Object} offset
	 */
	plotLineArea: function(series, offset){
		var data = series.data;
		if(data.length < 2) return;

		var top, lastX = 0,
			ctx = this.ctx,
			xa = series.xaxis,
			ya = series.yaxis,
			tHoz = this.tHoz.bind(this),
			tVert = this.tVert.bind(this),
			bottom = Math.min(Math.max(0, ya.min), ya.max),
			first = true;
		
		ctx.beginPath();
		for(var i = 0; i < data.length - 1; ++i){
			
			var x1 = data[i][0], y1 = data[i][1],
			    x2 = data[i+1][0], y2 = data[i+1][1];
			
			if(x1 <= x2 && x1 < xa.min){
				if(x2 < xa.min) continue;
				y1 = (xa.min - x1) / (x2 - x1) * (y2 - y1) + y1;
				x1 = xa.min;
			}
			else if(x2 <= x1 && x2 < xa.min){
				if(x1 < xa.min) continue;
				y2 = (xa.min - x1) / (x2 - x1) * (y2 - y1) + y1;
				x2 = xa.min;
			}
								
			if(x1 >= x2 && x1 > xa.max){
				if(x2 > xa.max) continue;
				y1 = (xa.max - x1) / (x2 - x1) * (y2 - y1) + y1;
				x1 = xa.max;
			}
			else if(x2 >= x1 && x2 > xa.max){
				if (x1 > xa.max) continue;
				y2 = (xa.max - x1) / (x2 - x1) * (y2 - y1) + y1;
				x2 = xa.max;
			}

			if(first){
				ctx.moveTo(tHoz(x1, xa), tVert(bottom, ya) + offset);
				first = false;
			}
			
			/**
			 * Now check the case where both is outside.
			 */
			if(y1 >= ya.max && y2 >= ya.max){
				ctx.lineTo(tHoz(x1, xa), tVert(ya.max, ya) + offset);
				ctx.lineTo(tHoz(x2, xa), tVert(ya.max, ya) + offset);
				continue;
			}
			else if(y1 <= ya.min && y2 <= ya.min){
				ctx.lineTo(tHoz(x1, xa), tVert(ya.min, ya) + offset);
				ctx.lineTo(tHoz(x2, xa), tVert(ya.min, ya) + offset);
				continue;
			}
			
			/**
			 * Else it's a bit more complicated, there might
			 * be two rectangles and two triangles we need to fill
			 * in; to find these keep track of the current x values.
			 */
			var x1old = x1, x2old = x2;
			
			/**
			 * And clip the y values, without shortcutting.
			 * Clip with ymin.
			 */
			if(y1 <= y2 && y1 < ya.min && y2 >= ya.min){
				x1 = (ya.min - y1) / (y2 - y1) * (x2 - x1) + x1;
				y1 = ya.min;
			}
			else if(y2 <= y1 && y2 < ya.min && y1 >= ya.min){
				x2 = (ya.min - y1) / (y2 - y1) * (x2 - x1) + x1;
				y2 = ya.min;
			}

			/**
			 * Clip with ymax.
			 */
			if(y1 >= y2 && y1 > ya.max && y2 <= ya.max){
				x1 = (ya.max - y1) / (y2 - y1) * (x2 - x1) + x1;
				y1 = ya.max;
			}
			else if(y2 >= y1 && y2 > ya.max && y1 <= ya.max){
				x2 = (ya.max - y1) / (y2 - y1) * (x2 - x1) + x1;
				y2 = ya.max;
			}

			/**
			 * If the x value was changed we got a rectangle to fill.
			 */
			if(x1 != x1old){
				top = (y1 <= ya.min) ? top = ya.min : ya.max;
				ctx.lineTo(tHoz(x1old, xa), tVert(top, ya) + offset);
				ctx.lineTo(tHoz(x1, xa), tVert(top, ya) + offset);
			}
		   	
			/**
			 * Fill the triangles.
			 */
			ctx.lineTo(tHoz(x1, xa), tVert(y1, ya) + offset);
			ctx.lineTo(tHoz(x2, xa), tVert(y2, ya) + offset);

			/**
			 * Fill the other rectangle if it's there.
			 */
			if(x2 != x2old){
				top = (y2 <= ya.min) ? ya.min : ya.max;
				ctx.lineTo(tHoz(x2old, xa), tVert(top, ya) + offset);
				ctx.lineTo(tHoz(x2, xa), tVert(top, ya) + offset);
			}

			lastX = Math.max(x2, x2old);
		}
		
		ctx.lineTo(tHoz(lastX, xa), tVert(bottom, ya) + offset);
		ctx.closePath();
		ctx.fill();
	},
	/**
	 * Draws lines series in the canvas element.
	 * @param {Object} series - Series with options.lines.show = true.
	 */
	drawSeriesLines: function(series){
		series = series || this.series;
		var ctx = this.ctx;
		ctx.save();
		ctx.translate(this.plotOffset.left, this.plotOffset.top);
		ctx.lineJoin = 'round';

		var lw = series.lines.lineWidth;
		var sw = series.shadowSize;

		if(sw > 0){
			ctx.lineWidth = sw / 2;

			var offset = lw/2 + ctx.lineWidth/2;
			
			ctx.strokeStyle = "rgba(0,0,0,0.1)";
			this.plotLine(series, offset + sw/2);

			ctx.strokeStyle = "rgba(0,0,0,0.2)";
			this.plotLine(series, offset);

			if(series.lines.fill) {
				ctx.fillStyle = "rgba(0,0,0,0.05)";
				this.plotLineArea(series, offset + sw/2);
			}
		}

		ctx.lineWidth = lw;
		ctx.strokeStyle = series.color;
		if(series.lines.fill){
			ctx.fillStyle = series.lines.fillColor != null ? series.lines.fillColor : Flotr.parseColor(series.color).scale(null, null, null, series.lines.fillOpacity).toString();
			this.plotLineArea(series, 0);
		}

		this.plotLine(series, 0);
		ctx.restore();
	},
	/**
	 * Draws point series in the canvas element.
	 * @param {Object} series - Series with options.points.show = true.
	 */
	drawSeriesPoints: function(series) {
		var ctx = this.ctx;
		
		ctx.save();
		ctx.translate(this.plotOffset.left, this.plotOffset.top);

		var lw = series.lines.lineWidth;
		var sw = series.shadowSize;
		
		if(sw > 0){
			ctx.lineWidth = sw / 2;
      
			ctx.strokeStyle = 'rgba(0,0,0,0.1)';
			this.plotPointShadows(series, sw/2 + ctx.lineWidth/2, series.points.radius);

			ctx.strokeStyle = 'rgba(0,0,0,0.2)';
			this.plotPointShadows(series, ctx.lineWidth/2, series.points.radius);
		}

		ctx.lineWidth = series.points.lineWidth;
		ctx.strokeStyle = series.color;
		ctx.fillStyle = series.points.fillColor != null ? series.points.fillColor : series.color;
		this.plotPoints(series, series.points.radius, series.points.fill);
		ctx.restore();
	},
	plotPoints: function (series, radius, fill) {
		var xa = series.xaxis,
		    ya = series.yaxis,
		    ctx = this.ctx, i,
		    data = series.data;
			
		for(i = data.length - 1; i > -1; --i){
			var x = data[i][0], y = data[i][1];
			// To allow empty values
			if(y === null || x < xa.min || x > xa.max || y < ya.min || y > ya.max)
				continue;
			
			ctx.beginPath();
			ctx.arc(this.tHoz(x, xa), this.tVert(y, ya), radius, 0, 2 * Math.PI, true);
			if(fill) ctx.fill();
			ctx.stroke();
		}
	},
	plotPointShadows: function(series, offset, radius){
		var xa = series.xaxis,
		    ya = series.yaxis,
		    ctx = this.ctx, i,
		    data = series.data;
			
		for(i = data.length - 1; i > -1; --i){
			var x = data[i][0], y = data[i][1];
			if (y === null || x < xa.min || x > xa.max || y < ya.min || y > ya.max)
				continue;
			ctx.beginPath();
			ctx.arc(this.tHoz(x, xa), this.tVert(y, ya) + offset, radius, 0, Math.PI, false);
			ctx.stroke();
		}
	},
	/**
	 * Draws bar series in the canvas element.
	 * @param {Object} series - Series with options.bars.show = true.
	 */
	drawSeriesBars: function(series) {
		var ctx = this.ctx,
			bw = series.bars.barWidth,
			lw = Math.min(series.bars.lineWidth, bw);
		
		ctx.save();
		ctx.translate(this.plotOffset.left, this.plotOffset.top);
		ctx.lineJoin = 'miter';

		/**
		 * @todo linewidth not interpreted the right way.
		 */
		ctx.lineWidth = lw;
		ctx.strokeStyle = series.color;
    
		this.plotBarsShadows(series, bw, 0, series.bars.fill);

		if(series.bars.fill){
			var color = series.bars.fillColor || series.color;
			ctx.fillStyle = Flotr.parseColor(color).scale(null, null, null, series.bars.fillOpacity).toString();
		}
    
		this.plotBars(series, bw, 0, series.bars.fill);
		ctx.restore();
	},
	plotBars: function(series, barWidth, offset, fill){
		var data = series.data;
		if(data.length < 1) return;
		
		var xa = series.xaxis,
		    ya = series.yaxis,
		    ctx = this.ctx,
		    tHoz = this.tHoz.bind(this),
		    tVert = this.tVert.bind(this);

		for(var i = 0; i < data.length; i++){
			var x = data[i][0],
			    y = data[i][1],
				drawLeft = true, drawTop = true, drawRight = true;
			
			if (y === null) continue;
			
			// Stacked bars
			var stackOffset = 0;
			if(series.bars.stacked) {
				$H(xa.values).each(function(pair) {
					if (pair.key == x) {
						stackOffset = pair.value.stack || 0;
						pair.value.stack = stackOffset + y;
					}
				});
			}

			// @todo: fix horizontal bars support
			// Horizontal bars
			if(series.bars.horizontal)
				var left = stackOffset, right = x + stackOffset, bottom = y, top = y + barWidth;
			else 
				var left = x - (series.bars.centered ? barWidth/2 : 0), right = x + barWidth - (series.bars.centered ? barWidth/2 : 0), bottom = stackOffset, top = y + stackOffset;

			if(right < xa.min || left > xa.max || top < ya.min || bottom > ya.max)
				continue;

			if(left < xa.min){
				left = xa.min;
				drawLeft = false;
			}

			if(right > xa.max){
				right = xa.max;
				if (xa.lastSerie != series && series.bars.horizontal)
					drawTop = false;
			}

			if(bottom < ya.min)
				bottom = ya.min;

			if(top > ya.max){
				top = ya.max;
				if (ya.lastSerie != series && !series.bars.horizontal)
					drawTop = false;
			}
      
			/**
			 * Fill the bar.
			 */
			if(fill){
				ctx.beginPath();
				ctx.moveTo(tHoz(left, xa), tVert(bottom, ya) + offset);
				ctx.lineTo(tHoz(left, xa), tVert(top, ya) + offset);
				ctx.lineTo(tHoz(right, xa), tVert(top, ya) + offset);
				ctx.lineTo(tHoz(right, xa), tVert(bottom, ya) + offset);
				ctx.fill();
			}

			/**
			 * Draw bar outline/border.
			 */
			if(series.bars.lineWidth != 0 && (drawLeft || drawRight || drawTop)){
				ctx.beginPath();
				ctx.moveTo(tHoz(left, xa), tVert(bottom, ya) + offset);
				
				ctx[drawLeft ?'lineTo':'moveTo'](tHoz(left, xa), tVert(top, ya) + offset);
				ctx[drawTop  ?'lineTo':'moveTo'](tHoz(right, xa), tVert(top, ya) + offset);
				ctx[drawRight?'lineTo':'moveTo'](tHoz(right, xa), tVert(bottom, ya) + offset);
				         
				ctx.stroke();
			}
		}
	},
	plotBarsShadows: function(series, barWidth, offset){
		var data = series.data;
		if(data.length < 1) return;
		
		var xa = series.xaxis,
		    ya = series.yaxis,
		    ctx = this.ctx,
		    tHoz = this.tHoz.bind(this),
		    tVert = this.tVert.bind(this),
		    sw = this.options.shadowSize;
		
		for(var i = 0; i < data.length; i++){
			var x = data[i][0],
			    y = data[i][1];
				
			if (y === null) continue;
			
			// Stacked bars
			var stackOffset = 0;
			if(series.bars.stacked) {
				$H(xa.values).each(function(pair) {
					if (pair.key == x) {
						stackOffset = pair.value.stackShadow || 0;
						pair.value.stackShadow = stackOffset + y;
					}
				});
			}
			
			// Horizontal bars
			if(series.bars.horizontal) 
				var left = stackOffset, right = x + stackOffset, bottom = y, top = y + barWidth;
			else 
				var left = x - (series.bars.centered ? barWidth/2 : 0), right = x + barWidth - (series.bars.centered ? barWidth/2 : 0), bottom = stackOffset, top = y + stackOffset;
			
			if(right < xa.min || left > xa.max || top < ya.min || bottom > ya.max)
				continue;
			
			if(left < xa.min)   left = xa.min;
			if(right > xa.max)  right = xa.max;
			if(bottom < ya.min) bottom = ya.min;
			if(top > ya.max)    top = ya.max;
			
			var width =  tHoz(right, xa)-tHoz(left, xa)-((tHoz(right, xa)+sw <= this.plotWidth) ? 0 : sw);
			var height = Math.max(0, tVert(bottom, ya)-tVert(top, ya)-((tVert(bottom, ya)+sw <= this.plotHeight) ? 0 : sw));
			
			ctx.fillStyle = 'rgba(0,0,0,0.05)';
			ctx.fillRect(Math.min(tHoz(left, xa)+sw, this.plotWidth), Math.min(tVert(top, ya)+sw, this.plotWidth), width, height);
		}
	},
	/**
	 * Draws candles series in the canvas element.
	 * @param {Object} series - Series with options.candles.show = true.
	 */
	drawSeriesCandles: function(series) {
		var ctx = this.ctx,
			  bw = series.candles.candleWidth;
		
		ctx.save();
		ctx.translate(this.plotOffset.left, this.plotOffset.top);
		ctx.lineJoin = 'miter';

		/**
		 * @todo linewidth not interpreted the right way.
		 */
		ctx.lineWidth = series.candles.lineWidth;
		this.plotCandlesShadows(series, bw/2);
		this.plotCandles(series, bw/2);
		
		ctx.restore();
	},
	plotCandles: function(series, offset){
		var data = series.data;
		if(data.length < 1) return;
		
		var xa = series.xaxis,
		    ya = series.yaxis,
		    ctx = this.ctx,
		    tHoz = this.tHoz.bind(this),
		    tVert = this.tVert.bind(this);

		for(var i = 0; i < data.length; i++){
			var d     = data[i],
			    x     = d[0],
			    open  = d[1],
			    high  = d[2],
			    low   = d[3],
			    close = d[4];

			var left    = x - series.candles.candleWidth/2,
			    right   = x + series.candles.candleWidth/2,
			    bottom  = Math.max(ya.min, low),
			    top     = Math.min(ya.max, high),
			    bottom2 = Math.max(ya.min, Math.min(open, close)),
			    top2    = Math.min(ya.max, Math.max(open, close));

			if(right < xa.min || left > xa.max || top < ya.min || bottom > ya.max)
				continue;

			var color = series.candles[open>close?'downFillColor':'upFillColor'];
			/**
			 * Fill the candle.
			 */
			if(series.candles.fill && !series.candles.barcharts){
				ctx.fillStyle = Flotr.parseColor(color).scale(null, null, null, series.candles.fillOpacity).toString();
				ctx.fillRect(tHoz(left, xa), tVert(top2, ya) + offset, tHoz(right, xa) - tHoz(left, xa), tVert(bottom2, ya) - tVert(top2, ya));
			}

			/**
			 * Draw candle outline/border, high, low.
			 */
			if(series.candles.lineWidth || series.candles.wickLineWidth){
				var x, y, pixelOffset = (series.candles.wickLineWidth % 2) / 2;

				x = Math.floor(tHoz((left + right) / 2), xa) + pixelOffset;
				
				ctx.save();
				ctx.strokeStyle = color;
				ctx.lineWidth = series.candles.wickLineWidth;
				ctx.lineCap = 'butt';
			  
				if (series.candles.barcharts) {
					ctx.beginPath();
					
					ctx.moveTo(x, Math.floor(tVert(top, ya) + offset));
					ctx.lineTo(x, Math.floor(tVert(bottom, ya) + offset));
					
					y = Math.floor(tVert(open, ya) + offset)+0.5;
					ctx.moveTo(Math.floor(tHoz(left, xa))+pixelOffset, y);
					ctx.lineTo(x, y);
					
					y = Math.floor(tVert(close, ya) + offset)+0.5;
					ctx.moveTo(Math.floor(tHoz(right, xa))+pixelOffset, y);
					ctx.lineTo(x, y);
				} 
				else {
					ctx.strokeRect(tHoz(left, xa), tVert(top2, ya) + offset, tHoz(right, xa) - tHoz(left, xa), tVert(bottom2, ya) - tVert(top2, ya));
					
					ctx.beginPath();
					ctx.moveTo(x, Math.floor(tVert(top2,    ya) + offset));
					ctx.lineTo(x, Math.floor(tVert(top,     ya) + offset));
					ctx.moveTo(x, Math.floor(tVert(bottom2, ya) + offset));
					ctx.lineTo(x, Math.floor(tVert(bottom,  ya) + offset));
				}
				
				ctx.stroke();
				ctx.restore();
			}
		}
	},
	plotCandlesShadows: function(series, offset){
		var data = series.data;
		if(data.length < 1 || series.candles.barcharts) return;
		
		var xa = series.xaxis,
		    ya = series.yaxis,
		    tHoz = this.tHoz.bind(this),
		    tVert = this.tVert.bind(this),
		    sw = this.options.shadowSize;
		
		for(var i = 0; i < data.length; i++){
			var d     = data[i],
			    x     = d[0],
			    open  = d[1],
			    high  = d[2],
			    low   = d[3],
			    close = d[4];
			
			var left   = x - series.candles.candleWidth/2,
			    right  = x + series.candles.candleWidth/2,
			    bottom = Math.max(ya.min, Math.min(open, close)),
			    top    = Math.min(ya.max, Math.max(open, close));
			
			if(right < xa.min || left > xa.max || top < ya.min || bottom > ya.max)
				continue;
			
			var width =  tHoz(right, xa)-tHoz(left, xa)-((tHoz(right, xa)+sw <= this.plotWidth) ? 0 : sw);
			var height = Math.max(0, tVert(bottom, ya)-tVert(top, ya)-((tVert(bottom, ya)+sw <= this.plotHeight) ? 0 : sw));
			
			this.ctx.fillStyle = 'rgba(0,0,0,0.05)';
			this.ctx.fillRect(Math.min(tHoz(left, xa)+sw, this.plotWidth), Math.min(tVert(top, ya)+sw, this.plotWidth), width, height);
		}
	},
	/**
	 * Draws a pie in the canvas element.
	 * @param {Object} series - Series with options.pie.show = true.
	 */
	drawSeriesPie: function(series) {
		if (this.options.pie.drawn) return;
		
		var ctx = this.ctx,
		    options = this.options,
		    lw = series.pie.lineWidth,
		    sw = series.shadowSize,
		    data = series.data,
		    plotOffset = this.plotOffset,
		    radius = (Math.min(this.canvasWidth, this.canvasHeight) * series.pie.sizeRatio) / 2,
		    html = [],
			vScale = 1,//Math.cos(series.pie.viewAngle);
			plotTickness = Math.sin(series.pie.viewAngle)*series.pie.spliceThickness / vScale,
		
		style = {
			size: options.fontSize*1.2,
			color: options.grid.color,
			weight: 1.5
		},
		
		center = {
			x: plotOffset.left + (this.plotWidth)/2,
			y: plotOffset.top + (this.plotHeight)/2
		},
		
		// Pie portions
		portions = this.series.collect(function(hash, index){
			if (hash.pie.show && hash.data[0][1] !== null)
				return {
					name: (hash.label || hash.data[0][1]),
					value: [index, hash.data[0][1]],
					options: hash.pie,
					series: hash
				};
		}),
		
		// Sum of the portions' angles
		sum = portions.pluck('value').pluck(1).inject(0, function(acc, n) { return acc + n; }),
		fraction = 0.0,
		angle = series.pie.startAngle,
		value = 0.0;
		
		var slices = portions.collect(function(slice){
			angle += fraction;
			value = parseFloat(slice.value[1]); // @warning : won't support null values !!
			fraction = value/sum;
			return {
				name:     slice.name,
				fraction: fraction,
				x:        slice.value[0],
				y:        value,
				options:  slice.options,
				series:   slice.series,
				startAngle: 2 * angle * Math.PI,
				endAngle:   2 * (angle + fraction) * Math.PI
			};
		});
		
		ctx.save();
		
		if(sw > 0){
			slices.each(function (slice) {
				if (slice.startAngle == slice.endAngle) return;
				
				var bisection = (slice.startAngle + slice.endAngle) / 2,
				    xOffset = center.x + Math.cos(bisection) * slice.options.explode + sw,
				    yOffset = center.y + Math.sin(bisection) * slice.options.explode + sw;
				
				this.plotSlice(xOffset, yOffset, radius, slice.startAngle, slice.endAngle, false, vScale);
				
				if (series.pie.fill) {
					ctx.fillStyle = 'rgba(0,0,0,0.1)';
					ctx.fill();
				}
			}, this);
		}
		
		if (options.HtmlText || !this.textEnabled)
			html = ['<div style="color:' + this.options.grid.color + '" class="flotr-labels">'];
		
		slices.each(function (slice, index) {
			if (slice.startAngle == slice.endAngle) return;
			
			var bisection = (slice.startAngle + slice.endAngle) / 2,
			    color = slice.series.color,
			    fillColor = slice.options.fillColor || color,
				xOffset = center.x + Math.cos(bisection) * slice.options.explode,
				yOffset = center.y + Math.sin(bisection) * slice.options.explode;
			
			this.plotSlice(xOffset, yOffset, radius, slice.startAngle, slice.endAngle, false, vScale);
			
			if(series.pie.fill){
				ctx.fillStyle = Flotr.parseColor(fillColor).scale(null, null, null, series.pie.fillOpacity).toString();
				ctx.fill();
			}
			ctx.lineWidth = lw;
			ctx.strokeStyle = color;
			ctx.stroke();
			
			var label = options.pie.labelFormatter(slice),
			    textAlignRight = (Math.cos(bisection) < 0),
			    distX = xOffset + Math.cos(bisection) * (series.pie.explode + radius),
				distY = yOffset + Math.sin(bisection) * (series.pie.explode + radius);
			
			if (slice.fraction && label) {
				if (options.HtmlText || !this.textEnabled) {
					var divStyle = 'position:absolute;top:' + (distY - 5) + 'px;'; //@todo: change
					if (textAlignRight)
						divStyle += 'right:'+(this.canvasWidth - distX)+'px;text-align:right;';
					else 
						divStyle += 'left:'+distX+'px;text-align:left;';
					html.push('<div style="' + divStyle + '" class="flotr-grid-label">' + label + '</div>');
				}
				else {
					style.halign = textAlignRight ? 'r' : 'l';
					ctx.drawText(
						label, 
						distX, 
						distY + style.size / 2, 
						style
					);
				}
			}
		}, this);
		
		if (options.HtmlText || !this.textEnabled) {
			html.push('</div>');    
			this.el.insert(html.join(''));
		}
		
		ctx.restore();
		options.pie.drawn = true;
	},
	plotSlice: function(x, y, radius, startAngle, endAngle, fill, vScale) {
		var ctx = this.ctx;
		vScale = vScale || 1;

		ctx.scale(1, vScale);
		ctx.beginPath();
		ctx.moveTo(x, y);
		ctx.arc   (x, y, radius, startAngle, endAngle, fill);
		ctx.lineTo(x, y);
		ctx.closePath();
	},
	/**
	 * Adds a legend div to the canvas container or draws it on the canvas.
	 */
	insertLegend: function(){
		if(!this.options.legend.show)
			return;
			
		var series = this.series,
			plotOffset = this.plotOffset,
			options = this.options,
			fragments = [],
			rowStarted = false, 
			ctx = this.ctx,
			i;
			
		var noLegendItems = series.findAll(function(s) {return (s.label && !s.hide)}).size();

		if (noLegendItems) {
		    if (!options.HtmlText && this.textEnabled) {
				var style = {
					size: options.fontSize*1.1,
					color: options.grid.color
				};
				
				// @todo: take css into account
				//var dummyDiv = this.el.insert('<div class="flotr-legend" style="position:absolute;top:-10000px;"></div>');
				
				var p = options.legend.position, 
				    m = options.legend.margin,
				    lbw = options.legend.labelBoxWidth,
				    lbh = options.legend.labelBoxHeight,
				    lbm = options.legend.labelBoxMargin,
				    offsetX = plotOffset.left + m,
				    offsetY = plotOffset.top + m;
				
				// We calculate the labels' max width
				var labelMaxWidth = 0;
				for(i = series.length - 1; i > -1; --i){
					if(!series[i].label || series[i].hide) continue;
					var label = options.legend.labelFormatter(series[i].label);	
					labelMaxWidth = Math.max(labelMaxWidth, ctx.measureText(label, style));
				}
				
				var legendWidth  = Math.round(lbw + lbm*3 + labelMaxWidth),
				    legendHeight = Math.round(noLegendItems*(lbm+lbh) + lbm);
				
				if(p.charAt(0) == 's') offsetY = plotOffset.top + this.plotHeight - (m + legendHeight);
				if(p.charAt(1) == 'e') offsetX = plotOffset.left + this.plotWidth - (m + legendWidth);
				
				// Legend box
				var color = Flotr.parseColor(options.legend.backgroundColor || 'rgb(240,240,240)').scale(null, null, null, options.legend.backgroundOpacity || 0.1).toString();
				
				ctx.fillStyle = color;
				ctx.fillRect(offsetX, offsetY, legendWidth, legendHeight);
				ctx.strokeStyle = options.legend.labelBoxBorderColor;
				ctx.strokeRect(Flotr.toPixel(offsetX), Flotr.toPixel(offsetY), legendWidth, legendHeight);
				
				// Legend labels
				var x = offsetX + lbm;
				var y = offsetY + lbm;
				for(i = 0; i < series.length; i++){
					if(!series[i].label || series[i].hide) continue;
					var label = options.legend.labelFormatter(series[i].label);
					
					ctx.fillStyle = series[i].color;
					ctx.fillRect(x, y, lbw-1, lbh-1);
					
					ctx.strokeStyle = options.legend.labelBoxBorderColor;
					ctx.lineWidth = 1;
					ctx.strokeRect(Math.ceil(x)-1.5, Math.ceil(y)-1.5, lbw+2, lbh+2);
					
					// Legend text
					ctx.drawText(
						label,
						x + lbw + lbm,
						y + (lbh + style.size - ctx.fontDescent(style))/2,
						style
					);
					
					y += lbh + lbm;
				}
		    }
		    else {
		  		for(i = 0; i < series.length; ++i){
		  			if(!series[i].label || series[i].hide) continue;
		  			
		  			if(i % options.legend.noColumns == 0){
		  				fragments.push(rowStarted ? '</tr><tr>' : '<tr>');
		  				rowStarted = true;
		  			}
		  
		  			var legend = options.legend,
		  			    s = series[i],
		  			    label = legend.labelFormatter(s.label),
		  			    boxWidth = legend.labelBoxWidth,
		  			    boxHeight = legend.labelBoxHeight,
		  			    opacity = 'opacity:' + s.bars.fillOpacity + ';filter:alpha(opacity=' + s.bars.fillOpacity + ');',
		  			    color = 'background-color:' + ((s.bars.show && s.bars.fillColor && s.bars.fill) ? s.bars.fillColor : s.color) + ';';
		  			
					fragments.push(
						'<td class="flotr-legend-color-box">',
							'<div style="border:1px solid ', legend.labelBoxBorderColor, ';padding:1px">',
								'<div style="width:', (boxWidth-1), 'px;height:', (boxHeight-1), 'px;border:1px solid ', series[i].color, '">', 
									'<div style="width:', boxWidth, 'px;height:', boxHeight, 'px;', opacity, color, '"></div>',
								'</div>',
							'</div>',
						'</td>',
						'<td class="flotr-legend-label">', label, '</td>'
					);
		  		}
		  		if(rowStarted) fragments.push('</tr>');
		  		
		  		if(fragments.length > 0){
		  			var table = '<table style="font-size:smaller;color:' + options.grid.color + '">' + fragments.join("") + '</table>';
		  			if(options.legend.container != null){
		  				$(options.legend.container).update(table);
		  			}
					else {
		  				var pos = '', p = options.legend.position, m = options.legend.margin;
		  				
		  				     if(p.charAt(0) == 'n') pos += 'top:' + (m + plotOffset.top) + 'px;';
		  				else if(p.charAt(0) == 's') pos += 'bottom:' + (m + plotOffset.bottom) + 'px;';					
		  				     if(p.charAt(1) == 'e') pos += 'right:' + (m + plotOffset.right) + 'px;';
		  				else if(p.charAt(1) == 'w') pos += 'left:' + (m + plotOffset.left) + 'px;';
		  				     
		  				var div = this.el.insert('<div class="flotr-legend" style="position:absolute;z-index:2;' + pos +'">' + table + '</div>').select('div.flotr-legend').first();
		  				
		  				if(options.legend.backgroundOpacity != 0.0){
		  					/**
		  					 * Put in the transparent background separately to avoid blended labels and
		  					 * label boxes.
		  					 */
		  					var c = options.legend.backgroundColor;
		  					if(c == null){
		  						var tmp = (options.grid.backgroundColor != null) ? options.grid.backgroundColor : Flotr.extractColor(div);
		  						c = Flotr.parseColor(tmp).adjust(null, null, null, 1).toString();
		  					}
		  					this.el.insert('<div class="flotr-legend-bg" style="position:absolute;width:' + div.getWidth() + 'px;height:' + div.getHeight() + 'px;' + pos +'background-color:' + c + ';"> </div>').select('div.flotr-legend-bg').first().setStyle({
		  						'opacity': options.legend.backgroundOpacity
		  					});						
		  				}
		  			}
		  		}
		    }
	    }
	},
	/**
	 * Calculates the coordinates from a mouse event object.
	 * @param {Event} event - Mouse Event object.
	 * @return {Object} Object with coordinates of the mouse.
	 */
	getEventPosition: function (event){
		var offset = this.overlay.cumulativeOffset(),
			rx = (event.pageX - offset.left - this.plotOffset.left),
			ry = (event.pageY - offset.top - this.plotOffset.top),
			ax = 0, ay = 0;
			
		if(event.pageX == null && event.clientX != null){
			var de = document.documentElement, b = document.body;
			ax = event.clientX + (de && de.scrollLeft || b.scrollLeft || 0);
			ay = event.clientY + (de && de.scrollTop || b.scrollTop || 0);
		}else{
			ax = event.pageX;
			ay = event.pageY;
		}
		
		return {
			x:  this.axes.x.min  + rx / this.axes.x.scale,
			x2: this.axes.x2.min + rx / this.axes.x2.scale,
			y:  this.axes.y.max  - ry / this.axes.y.scale,
			y2: this.axes.y2.max - ry / this.axes.y2.scale,
			relX: rx,
			relY: ry,
			absX: ax,
			absY: ay
		};
	},
	/**
	 * Observes the 'click' event and fires the 'flotr:click' event.
	 * @param {Event} event - 'click' Event object.
	 */
	clickHandler: function(event){
		if(this.ignoreClick){
			this.ignoreClick = false;
			return;
		}
		this.el.fire('flotr:click', [this.getEventPosition(event), this]);
	},
	/**
	 * Observes mouse movement over the graph area. Fires the 'flotr:mousemove' event.
	 * @param {Event} event - 'mousemove' Event object.
	 */
	mouseMoveHandler: function(event){
 		var pos = this.getEventPosition(event);
    
		this.lastMousePos.pageX = pos.absX;
		this.lastMousePos.pageY = pos.absY;	
    	
    	//@todo Add another overlay for the crosshair
		if (this.options.crosshair.mode)
			this.clearCrosshair();
			
		if(this.selectionInterval == null && (this.options.mouse.track || this.series.any(function(s){return s.mouse && s.mouse.track;})))
			this.hit(pos);
		
		if (this.options.crosshair.mode)
			this.drawCrosshair(pos);
    
		this.el.fire('flotr:mousemove', [event, pos, this]);
	},
	/**
	 * Observes the 'mousedown' event.
	 * @param {Event} event - 'mousedown' Event object.
	 */
	mouseDownHandler: function (event){
		if(event.isRightClick()) {
			event.stop();
			var overlay = this.overlay;
			
			overlay.hide();
			
			function cancelContextMenu () {
				overlay.show();
				$(document).stopObserving('mousemove', cancelContextMenu);
			}
			$(document).observe('mousemove', cancelContextMenu);
			return;
		}
    
		if(!this.options.selection.mode || !event.isLeftClick()) return;
		
		this.setSelectionPos(this.selection.first, event);				
		if(this.selectionInterval != null){
			clearInterval(this.selectionInterval);
		}
		this.lastMousePos.pageX = null;
		this.selectionInterval = setInterval(this.updateSelection.bind(this), 1000/this.options.selection.fps);
		
		this.mouseUpHandler = this.mouseUpHandler.bind(this);
		$(document).observe('mouseup', this.mouseUpHandler);
	},
	/**
	 * Fires the 'flotr:select' event when the user made a selection.
	 */
	fireSelectEvent: function(){
		var a = this.axes, selection = this.selection,
			x1 = (selection.first.x <= selection.second.x) ? selection.first.x : selection.second.x,
			x2 = (selection.first.x <= selection.second.x) ? selection.second.x : selection.first.x,
			y1 = (selection.first.y >= selection.second.y) ? selection.first.y : selection.second.y,
			y2 = (selection.first.y >= selection.second.y) ? selection.second.y : selection.first.y;
		
		x1 = a.x.min + x1 / a.x.scale;
		x2 = a.x.min + x2 / a.x.scale;
		y1 = a.y.max - y1 / a.y.scale;
		y2 = a.y.max - y2 / a.y.scale;

		this.el.fire('flotr:select', [{x1:x1, y1:y1, x2:x2, y2:y2}, this]);
	},
	/**
	 * Observes the mouseup event for the document. 
	 * @param {Event} event - 'mouseup' Event object.
	 */
	mouseUpHandler: function(event){
		$(document).stopObserving('mouseup', this.mouseUpHandler);
		event.stop();
    
		if(this.selectionInterval != null){
			clearInterval(this.selectionInterval);
			this.selectionInterval = null;
		}

		this.setSelectionPos(this.selection.second, event);
		this.clearSelection();
		
		if(this.selectionIsSane()){
			this.drawSelection();
			this.fireSelectEvent();
			this.ignoreClick = true;
		}
	},
	/**
	 * Calculates the position of the selection.
	 * @param {Object} pos - Position object.
	 * @param {Event} event - Event object.
	 */
	setSelectionPos: function(pos, event) {
		var options = this.options,
		    offset = $(this.overlay).cumulativeOffset();
		
		if(options.selection.mode.indexOf('x') == -1){
			pos.x = (pos == this.selection.first) ? 0 : this.plotWidth;			   
		}else{
			pos.x = event.pageX - offset.left - this.plotOffset.left;
			pos.x = Math.min(Math.max(0, pos.x), this.plotWidth);
		}

		if (options.selection.mode.indexOf('y') == -1){
			pos.y = (pos == this.selection.first) ? 0 : this.plotHeight;
		}else{
			pos.y = event.pageY - offset.top - this.plotOffset.top;
			pos.y = Math.min(Math.max(0, pos.y), this.plotHeight);
		}
	},
	/**
	 * Updates (draws) the selection box.
	 */
	updateSelection: function(){
		if(this.lastMousePos.pageX == null) return;
		
		this.setSelectionPos(this.selection.second, this.lastMousePos);
		this.clearSelection();
		
		if(this.selectionIsSane()) this.drawSelection();
	},
	/**
	 * Removes the selection box from the overlay canvas.
	 */
	clearSelection: function() {
		if(this.prevSelection == null) return;
			
		var prevSelection = this.prevSelection,
			lw = this.octx.lineWidth,
			plotOffset = this.plotOffset,
			x = Math.min(prevSelection.first.x, prevSelection.second.x),
			y = Math.min(prevSelection.first.y, prevSelection.second.y),
			w = Math.abs(prevSelection.second.x - prevSelection.first.x),
			h = Math.abs(prevSelection.second.y - prevSelection.first.y);
		
		this.octx.clearRect(x + plotOffset.left - lw/2+0.5,
		                    y + plotOffset.top - lw/2+0.5,
		                    w + lw,
		                    h + lw);
		
		this.prevSelection = null;
	},
	/**
	 * Allows the user the manually select an area.
	 * @param {Object} area - Object with coordinates to select.
	 */
	setSelection: function(area){
		var options = this.options,
			xa = this.axes.x,
			ya = this.axes.y,
			vertScale = ya.scale,
			hozScale = xa.scale,
			selX = options.selection.mode.indexOf('x') != -1,
			selY = options.selection.mode.indexOf('y') != -1;
		
		this.clearSelection();

		this.selection.first.y  = selX ? 0 : (ya.max - area.y1) * vertScale;
		this.selection.second.y = selX ? this.plotHeight : (ya.max - area.y2) * vertScale;			
		this.selection.first.x  = selY ? 0 : (area.x1 - xa.min) * hozScale;
		this.selection.second.x = selY ? this.plotWidth : (area.x2 - xa.min) * hozScale;
		
		this.drawSelection();
		this.fireSelectEvent();
	},
	/**
	 * Draws the selection box.
	 */
	drawSelection: function() {
		var prevSelection = this.prevSelection,
			selection = this.selection,
			octx = this.octx,
			options = this.options,
			plotOffset = this.plotOffset;
		
		if(prevSelection != null &&
			selection.first.x == prevSelection.first.x &&
			selection.first.y == prevSelection.first.y && 
			selection.second.x == prevSelection.second.x &&
			selection.second.y == prevSelection.second.y)
			return;
		
		octx.save();
		octx.strokeStyle = Flotr.parseColor(options.selection.color).scale(null, null, null, 0.8).toString();
		octx.lineWidth = 1;
		octx.lineJoin = 'miter';
		octx.fillStyle = Flotr.parseColor(options.selection.color).scale(null, null, null, 0.4).toString();

		this.prevSelection = {
			first: { x: selection.first.x, y: selection.first.y },
			second: { x: selection.second.x, y: selection.second.y }
		};

		var x = Math.min(selection.first.x, selection.second.x),
		    y = Math.min(selection.first.y, selection.second.y),
		    w = Math.abs(selection.second.x - selection.first.x),
		    h = Math.abs(selection.second.y - selection.first.y);
		
		octx.fillRect(x + plotOffset.left+0.5, y + plotOffset.top+0.5, w, h);
		octx.strokeRect(x + plotOffset.left+0.5, y + plotOffset.top+0.5, w, h);
		octx.restore();
	},
	/**	 
	 * Draws the selection box.
	 */
	drawCrosshair: function(pos) {
		var octx = this.octx,
			options = this.options,
			plotOffset = this.plotOffset,
			x = plotOffset.left+pos.relX+0.5,
			y = plotOffset.top+pos.relY+0.5,
			modeX = options.crosshair.mode.indexOf('x') != -1,
			modeY = options.crosshair.mode.indexOf('y') != -1;
		
		if (pos.relX < 0 || pos.relY < 0 || pos.relX > this.plotWidth || pos.relY > this.plotHeight) {
			this.el.style.cursor = null;
			this.el.removeClassName('flotr-crosshair');
			return; 
		}
		
		this.lastMousePos.relX = null;
		this.lastMousePos.relY = null;
		
		if (options.crosshair.hideCursor) {
			this.el.style.cursor = 'url(blank.cur), crosshair';
			this.el.addClassName('flotr-crosshair');
		}
		
		octx.save();
		octx.strokeStyle = options.crosshair.color;
		octx.lineWidth = 1;
		octx.beginPath();
		
		if (modeX) {
			octx.moveTo(x, plotOffset.top);
			octx.lineTo(x, plotOffset.top + this.plotHeight);
			this.lastMousePos.relX = x;
		}
		
		if (modeY) {
			octx.moveTo(plotOffset.left, y);
			octx.lineTo(plotOffset.left + this.plotWidth, y);
			this.lastMousePos.relY = y;
		}
		
		octx.stroke();
		octx.restore();
	},
	/**
	 * Removes the selection box from the overlay canvas.
	 */
	clearCrosshair: function() {
		if (this.lastMousePos.relX != null)
		this.octx.clearRect(this.lastMousePos.relX-0.5,
		                    this.plotOffset.top,
		                    1,
		                    this.plotHeight+1);
							
		if (this.lastMousePos.relY != null)
		this.octx.clearRect(this.plotOffset.left,
		                    this.lastMousePos.relY-0.5,
		                    this.plotWidth+1,
		                    1);		
	},
	/**
	 * Determines whether or not the selection is sane and should be drawn.
	 * @return {Boolean} - True when sane, false otherwise.
	 */
	selectionIsSane: function(){
		return Math.abs(this.selection.second.x - this.selection.first.x) >= 5 &&
		       Math.abs(this.selection.second.y - this.selection.first.y) >= 5;
	},
	/**
	 * Removes the mouse tracking point from the overlay.
	 */
	clearHit: function(){
		if(!this.prevHit) return;
    
		var prevHit = this.prevHit,
		    plotOffset = this.plotOffset,
		    s = prevHit.series,
		    lw = s.bars.lineWidth;
				
		if(!s.bars.show){
			var r = s.points.radius;
			this.octx.clearRect(
				this.tHoz(prevHit.x, prevHit.xaxis) + plotOffset.left - r*2,
				this.tVert(prevHit.y, prevHit.yaxis) + plotOffset.top - r*2,
				r*3 + s.points.lineWidth*3, 
				r*3 + s.points.lineWidth*3
			);
		}

		else {
			var bw = s.bars.barWidth;
			this.octx.clearRect(
				this.tHoz(prevHit.x - bw/2, prevHit.xaxis) + plotOffset.left - lw, 
				this.tVert(prevHit.y, prevHit.yaxis) + plotOffset.top - lw, 
				this.tHoz(bw, prevHit.xaxis) + lw * 2, 
				this.tVert(0, prevHit.yaxis) + lw * 2
			);
		}
	},
	/**
	 * Updates the mouse tracking point on the overlay.
	 */
	drawHit: function(n){
		var octx = this.octx,
		    s = n.series,
		    tHoz = this.tHoz.bind(this),
		    tVert = this.tVert.bind(this);

		if(s.mouse.lineColor != null){
			octx.save();
			octx.lineWidth = s.points.lineWidth;
			octx.strokeStyle = s.mouse.lineColor;
      octx.fillStyle = Flotr.parseColor(s.mouse.fillColor || '#ffffff').scale(null,null,null, s.mouse.fillOpacity).toString();
      
			if(!s.bars.show){
				octx.translate(this.plotOffset.left, this.plotOffset.top);
				octx.beginPath();
				octx.arc(tHoz(n.x, n.xaxis), tVert(n.y, n.yaxis), s.mouse.radius, 0, 2 * Math.PI, true);
				octx.fill();
				octx.stroke();
			}

			else {
				var bw = s.bars.barWidth;
				
				octx.save();
				octx.translate(this.plotOffset.left, this.plotOffset.top);
				octx.beginPath();
				octx.moveTo(tHoz(n.x-(bw/2), n.xaxis), tVert(n.yaxis.min, n.yaxis));
				octx.lineTo(tHoz(n.x-(bw/2), n.xaxis), tVert(n.y, n.yaxis));
				octx.lineTo(tHoz(n.x+(bw/2), n.xaxis), tVert(n.y, n.yaxis));
				octx.lineTo(tHoz(n.x+(bw/2), n.xaxis), tVert(n.yaxis.min, n.yaxis));
				octx.stroke();
				octx.closePath();
				
				if(s.mouse.fillColor){ 
					octx.beginPath();
					octx.moveTo(tHoz(n.x-(bw/2), n.xaxis), tVert(n.yaxis.min, n.yaxis));
					octx.lineTo(tHoz(n.x-(bw/2), n.xaxis), tVert(n.y, n.yaxis));
					octx.lineTo(tHoz(n.x+(bw/2), n.xaxis), tVert(n.y, n.yaxis));
					octx.lineTo(tHoz(n.x+(bw/2), n.xaxis), tVert(n.yaxis.min, n.yaxis));
					octx.fill();
					octx.closePath();
				}
        
				octx.restore();
			}
			octx.restore();
		}
		this.prevHit = n;
	},
	/**
	 * Retrieves the nearest data point from the mouse cursor. If it's within
	 * a certain range, draw a point on the overlay canvas and display the x and y
	 * value of the data.
	 * @param {Object} mouse - Object that holds the relative x and y coordinates of the cursor.
	 */
	hit: function(mouse){
		var series = this.series,
			options = this.options,
			prevHit = this.prevHit,
			plotOffset = this.plotOffset,
			octx = this.octx, 
			data, xsens, ysens, x, y, xa, ya, mx, my, 
			/**
			 * Nearest data element.
			 */
			i, n = {
				dist:Number.MAX_VALUE,
				x:null,
				y:null,
				relX:mouse.relX,
				relY:mouse.relY,
				absX:mouse.absX,
				absY:mouse.absY,
				mouse:null,
				xaxis:null,
				yaxis:null,
				series:null,
				index:null
			};
		
		for(i = 0; i < series.length; i++){
			s = series[i];
			if(!s.mouse.track) continue;
			data = s.data;
			xa = s.xaxis;
			ya = s.yaxis;
			xsens = (2*options.points.lineWidth)/xa.scale * s.mouse.sensibility;
			ysens = (2*options.points.lineWidth)/ya.scale * s.mouse.sensibility;
			mx =  mouse.relX/xa.scale + xa.min;
			my = -mouse.relY/ya.scale + ya.max;
			
			for(var j = 0, xpow, ypow; j < data.length; j++){
				x = data[j][0];
				y = data[j][1];
				
				if (y === null || 
				    xa.min > x || xa.max < x || 
				    ya.min > y || ya.max < y) continue;
				
				var xdiff = Math.abs(x - mx),
				    ydiff = Math.abs(y - my);
				
				// we use a different set of criteria to determin if there has been a hit
				// depending on what type of graph we have
				if(((!s.bars.show) && xdiff < xsens && ydiff < ysens) || 
				    (s.bars.show && xdiff < s.bars.barWidth/2 && my > ya.min && my < y)){
					var distance = Math.sqrt(xdiff*xdiff + ydiff*ydiff);
					if(distance < n.dist){
						n.dist = distance;
						n.x = x;
						n.y = y;
						n.xaxis = xa;
						n.yaxis = ya;
						n.mouse = s.mouse;
						n.series = s;
						n.index = j;
					}
				}
			}
		}
		
		if(n.series && (n.mouse && n.mouse.track && !prevHit || (prevHit /*&& (n.x != prevHit.x || n.y != prevHit.y)*/))){
			var mt = this.mouseTrack || this.el.select(".flotr-mouse-value")[0],
			    pos = '', 
			    s = n.series,
			    p = n.mouse.position, 
			    m = n.mouse.margin,
			    elStyle = 'opacity:0.7;background-color:#000;color:#fff;display:none;position:absolute;padding:2px 8px;-moz-border-radius:4px;border-radius:4px;white-space:nowrap;';
			
			if (!n.mouse.relative) { // absolute to the canvas
				     if(p.charAt(0) == 'n') pos += 'top:' + (m + plotOffset.top) + 'px;';
				else if(p.charAt(0) == 's') pos += 'bottom:' + (m + plotOffset.bottom) + 'px;';					
				     if(p.charAt(1) == 'e') pos += 'right:' + (m + plotOffset.right) + 'px;';
				else if(p.charAt(1) == 'w') pos += 'left:' + (m + plotOffset.left) + 'px;';
			}
			else { // relative to the mouse or in the case of bar like graphs to the bar
				if(!s.bars.show){
					     if(p.charAt(0) == 'n') pos += 'bottom:' + (m - plotOffset.top - this.tVert(n.y, n.yaxis) + this.canvasHeight) + 'px;';
					else if(p.charAt(0) == 's') pos += 'top:' + (m + plotOffset.top + this.tVert(n.y, n.yaxis)) + 'px;';
					     if(p.charAt(1) == 'e') pos += 'left:' + (m + plotOffset.left + this.tHoz(n.x, n.xaxis)) + 'px;';
					else if(p.charAt(1) == 'w') pos += 'right:' + (m - plotOffset.left - this.tHoz(n.x, n.xaxis) + this.canvasWidth) + 'px;';
				}

				else {
					pos += 'bottom:' + (m - plotOffset.top - this.tVert(n.yaxis.min+((n.y-n.yaxis.min)/2), n.yaxis) + this.canvasHeight) + 'px;';
					pos += 'left:' + (m + plotOffset.left + this.tHoz(n.x - options.bars.barWidth/2 , n.xaxis)) + 'px;';
				}
			}
			
			elStyle += pos;
				     
			if(!mt){
				this.el.insert('<div class="flotr-mouse-value" style="'+elStyle+'"></div>');
				mt = this.mouseTrack = this.el.select('.flotr-mouse-value').first();
			}
			else {
				this.mouseTrack = mt.setStyle(elStyle);
			}
			
			if(n.x !== null && n.y !== null){
				mt.show();
				
				this.clearHit();
				this.drawHit(n);
				
				var decimals = n.mouse.trackDecimals;
				if(decimals == null || decimals < 0) decimals = 0;
				
				mt.innerHTML = n.mouse.trackFormatter({x: n.x.toFixed(decimals), y: n.y.toFixed(decimals), series: n.series, index: n.index});
				mt.fire('flotr:hit', [n, this]);
			}
			else if(prevHit){
				mt.hide();
				this.clearHit();
			}
		}
		else if(this.prevHit) {
			this.mouseTrack.hide();
			this.clearHit();
		}
	},
	saveImage: function (type, width, height, replaceCanvas) {
		var image = null;
		switch (type) {
			case 'jpeg':
			case 'jpg': image = Canvas2Image.saveAsJPEG(this.canvas, replaceCanvas, width, height); break;
			default:
			case 'png': image = Canvas2Image.saveAsPNG(this.canvas, replaceCanvas, width, height); break;
			case 'bmp': image = Canvas2Image.saveAsBMP(this.canvas, replaceCanvas, width, height); break;
		}
		if (Object.isElement(image) && replaceCanvas) {
			this.restoreCanvas();
			this.canvas.hide();
			this.overlay.hide();
			this.el.insert(image.setStyle({position: 'absolute'}));
		}
	},
	restoreCanvas: function() {
		this.canvas.show();
		this.overlay.show();
		this.el.select('img').invoke('remove');
	}
});

Flotr.Color = Class.create({
	initialize: function(r, g, b, a){
		this.rgba = ['r','g','b','a'];
		var x = 4;
		while(-1<--x){
			this[this.rgba[x]] = arguments[x] || ((x==3) ? 1.0 : 0);
		}
		this.normalize();
	},
	
	adjust: function(rd, gd, bd, ad) {
		var x = 4;
		while(-1<--x){
			if(arguments[x] != null)
				this[this.rgba[x]] += arguments[x];
		}
		return this.normalize();
	},
	
	clone: function(){
		return new Flotr.Color(this.r, this.b, this.g, this.a);
	},
	
	limit: function(val,minVal,maxVal){
		return Math.max(Math.min(val, maxVal), minVal);
	},
	
	normalize: function(){
		var limit = this.limit;
		this.r = limit(parseInt(this.r), 0, 255);
		this.g = limit(parseInt(this.g), 0, 255);
		this.b = limit(parseInt(this.b), 0, 255);
		this.a = limit(this.a, 0, 1);
		return this;
	},
	
	scale: function(rf, gf, bf, af){
		var x = 4;
		while(-1<--x){
			if(arguments[x] != null)
				this[this.rgba[x]] *= arguments[x];
		}
		return this.normalize();
	},
	
	distance: function(color){
		if (!color) return;
		color = new Flotr.parseColor(color);
		var dist = 0, x = 3;
		while(-1<--x){
			dist += Math.abs(this[this.rgba[x]] - color[this.rgba[x]]);
		}
		return dist;
	},
	
	toString: function(){
		return (this.a >= 1.0) ? 'rgb('+[this.r,this.g,this.b].join(',')+')' : 'rgba('+[this.r,this.g,this.b,this.a].join(',')+')';
	}
});

Flotr.Color.lookupColors = {
	aqua:[0,255,255],
	azure:[240,255,255],
	beige:[245,245,220],
	black:[0,0,0],
	blue:[0,0,255],
	brown:[165,42,42],
	cyan:[0,255,255],
	darkblue:[0,0,139],
	darkcyan:[0,139,139],
	darkgrey:[169,169,169],
	darkgreen:[0,100,0],
	darkkhaki:[189,183,107],
	darkmagenta:[139,0,139],
	darkolivegreen:[85,107,47],
	darkorange:[255,140,0],
	darkorchid:[153,50,204],
	darkred:[139,0,0],
	darksalmon:[233,150,122],
	darkviolet:[148,0,211],
	fuchsia:[255,0,255],
	gold:[255,215,0],
	green:[0,128,0],
	indigo:[75,0,130],
	khaki:[240,230,140],
	lightblue:[173,216,230],
	lightcyan:[224,255,255],
	lightgreen:[144,238,144],
	lightgrey:[211,211,211],
	lightpink:[255,182,193],
	lightyellow:[255,255,224],
	lime:[0,255,0],
	magenta:[255,0,255],
	maroon:[128,0,0],
	navy:[0,0,128],
	olive:[128,128,0],
	orange:[255,165,0],
	pink:[255,192,203],
	purple:[128,0,128],
	violet:[128,0,128],
	red:[255,0,0],
	silver:[192,192,192],
	white:[255,255,255],
	yellow:[255,255,0]
};

// not used yet
Flotr.Date = {
	format: function(d, format) {
		if (!d) return;

		var leftPad = function(n) {
			n = n.toString();
			return n.length == 1 ? "0" + n : n;
		};
		
		var r = [], c,
		    escape = false;
		
		for (var i = 0; i < format.length; ++i) {
			c = format.charAt(i);
			
			if (escape) {
				switch (c) {
					case 'h': c = d.getUTCHours().toString(); break;
					case 'H': c = leftPad(d.getUTCHours()); break;
					case 'M': c = leftPad(d.getUTCMinutes()); break;
					case 'S': c = leftPad(d.getUTCSeconds()); break;
					case 'd': c = d.getUTCDate().toString(); break;
					case 'm': c = (d.getUTCMonth() + 1).toString(); break;
					case 'y': c = d.getUTCFullYear().toString(); break;
					case 'b': c = Flotr.Date.monthNames[d.getUTCMonth()]; break;
				}
				r.push(c);
				escape = false;
			}
			else {
				if (c == "%")
					escape = true;
				else
					r.push(c);
			}
		}
		return r.join("");
	},
	formatter: function (v, axis) {
		var d = new Date(v);

		// first check global format
		if (axis.options.timeformat != null)
			return Flotr.Date.format(d, axis.options.timeformat);
		
		var t = axis.tickSize[0] * Flotr.Date.timeUnits[axis.tickSize[1]],
		    span = axis.max - axis.min;
		
		if (t < Flotr.Date.timeUnits.minute)
			fmt = "%h:%M:%S";
		else if (t < Flotr.Date.timeUnits.day)
			fmt = (span < 2 * Flotr.Date.timeUnits.day) ? "%h:%M" : "%b %d %h:%M";
		else if (t < Flotr.Date.timeUnits.month)
			fmt = "%b %d";
		else if (t < Flotr.Date.timeUnits.year) 
			fmt = (span < Flotr.Date.timeUnits.year) ? "%b" : "%b %y";
		else 
			fmt = "%y";
		
		return Flotr.Date.format(d, fmt);
	},
	generator: function(axis) {
		var ticks = [],
			tickSize = axis.tickSize[0], unit = axis.tickSize[1],
			d = new Date(axis.min),
			step = tickSize * timeUnitSize[unit];

		switch (unit) {
			case "second": d.setUTCSeconds(floorInBase(d.getUTCSeconds(), tickSize)); break;
			case "minute": d.setUTCMinutes(floorInBase(d.getUTCMinutes(), tickSize)); break;
			case "hour":   d.setUTCHours(floorInBase(d.getUTCHours(), tickSize)); break;
			case "month":  d.setUTCMonth(floorInBase(d.getUTCMonth(), tickSize)); break;
			case "year":   d.setUTCFullYear(floorInBase(d.getUTCFullYear(), tickSize));break;
		}
		
		// reset smaller components
		d.setUTCMilliseconds(0);
		if (step >= timeUnitSize.minute)  d.setUTCSeconds(0);
		if (step >= timeUnitSize.hour)    d.setUTCMinutes(0);
		if (step >= timeUnitSize.day)     d.setUTCHours(0);
		if (step >= timeUnitSize.day * 4) d.setUTCDate(1);
		if (step >= timeUnitSize.year)    d.setUTCMonth(0);

		var carry = 0, v = Number.NaN, prev;
		do {
			prev = v;
			v = d.getTime();
			ticks.push({ v: v, label: axis.tickFormatter(v, axis) });
			if (unit == "month") {
				if (tickSize < 1) {
					/* a bit complicated - we'll divide the month up but we need to take care of fractions
					 so we don't end up in the middle of a day */
					d.setUTCDate(1);
					var start = d.getTime();
					d.setUTCMonth(d.getUTCMonth() + 1);
					var end = d.getTime();
					d.setTime(v + carry * timeUnitSize.hour + (end - start) * tickSize);
					carry = d.getUTCHours();
					d.setUTCHours(0);
				}
				else
					d.setUTCMonth(d.getUTCMonth() + tickSize);
			}
			else if (unit == "year") {
				d.setUTCFullYear(d.getUTCFullYear() + tickSize);
			}
			else
				d.setTime(v + step);
		} while (v < axis.max && v != prev);

		return ticks;
	},
	timeUnits: {
		second: 1000,
		minute: 1000 * 60,
		hour:   1000 * 60 * 60,
		day:    1000 * 60 * 60 * 24,
		month:  1000 * 60 * 60 * 24 * 30,
		year:   1000 * 60 * 60 * 24 * 30 * 365.2425
	},
	// the allowed tick sizes, after 1 year we use an integer algorithm
	spec: [
		[1, "second"],   [2, "second"],  [5, "second"], [10, "second"], [30, "second"], 
		[1, "minute"],   [2, "minute"],  [5, "minute"], [10, "minute"], [30, "minute"], 
		[1, "hour"],     [2, "hour"],    [4, "hour"],   [8, "hour"],    [12, "hour"],
		[1, "day"],      [2, "day"],     [3, "day"],
		[0.25, "month"], [0.5, "month"], [1, "month"],  [2, "month"],   [3, "month"], [6, "month"],
		[1, "year"]
	],
	monthNames: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
};
