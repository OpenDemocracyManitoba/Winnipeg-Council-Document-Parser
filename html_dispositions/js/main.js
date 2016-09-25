$( document ).ready(function() {
    capitalized_phrases_chart();
    //$(".speaker blockquote").readmore({ maxHeight: 100 });
});

function capitalized_phrases_chart() {
    var options = {
        height: 260,
        reverseData: true,
        horizontalBars: true,
        axisY: {
          offset: 240,
          scaleMinSpace: 0
        },

        axisX: {
            labelInterpolationFnc: function(value) {
                return (isNaN(value) || value % 1 == 0 ) ? value : ' '; // Only use whole numbers.
            }
        }
    }

    // Create a new line chart object where as first parameter we pass in a selector
    // that is resolving to our chart container element. The Second parameter
    // is the actual data object.
    new Chartist.Bar('.ct-chart.capitalized-phrases', capitalized_phrases, options);

    options['axisY']['offset'] = 100;

    new Chartist.Bar('.ct-chart.popular-terms', popular_terms, options);

    options['axisY']['offset'] = 200;
    options['height'] = 510;

//    new Chartist.Bar('.ct-chart.words-spoken', words_spoken_by_councillors, options);
}
