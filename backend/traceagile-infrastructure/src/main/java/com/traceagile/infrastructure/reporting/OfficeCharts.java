package com.traceagile.infrastructure.reporting;

import com.traceagile.application.reporting.ReportDocument.Chart;
import com.traceagile.application.reporting.ReportDocument.ChartType;
import com.traceagile.application.reporting.ReportDocument.Series;
import java.util.HexFormat;
import java.util.List;
import org.apache.poi.xddf.usermodel.XDDFColor;
import org.apache.poi.xddf.usermodel.XDDFLineProperties;
import org.apache.poi.xddf.usermodel.XDDFSolidFillProperties;
import org.apache.poi.xddf.usermodel.chart.AxisCrosses;
import org.apache.poi.xddf.usermodel.chart.AxisPosition;
import org.apache.poi.xddf.usermodel.chart.BarDirection;
import org.apache.poi.xddf.usermodel.chart.BarGrouping;
import org.apache.poi.xddf.usermodel.chart.ChartTypes;
import org.apache.poi.xddf.usermodel.chart.LegendPosition;
import org.apache.poi.xddf.usermodel.chart.MarkerStyle;
import org.apache.poi.xddf.usermodel.chart.XDDFBarChartData;
import org.apache.poi.xddf.usermodel.chart.XDDFCategoryAxis;
import org.apache.poi.xddf.usermodel.chart.XDDFChart;
import org.apache.poi.xddf.usermodel.chart.XDDFChartData;
import org.apache.poi.xddf.usermodel.chart.XDDFDataSource;
import org.apache.poi.xddf.usermodel.chart.XDDFLineChartData;
import org.apache.poi.xddf.usermodel.chart.XDDFNumericalDataSource;
import org.apache.poi.xddf.usermodel.chart.XDDFValueAxis;

/** ADR-0023 graphiques natifs Word / Excel (POI XDDF), modifiables par l'utilisateur. */
final class OfficeCharts {

    private OfficeCharts() {
    }

    /** Valeurs d'une série : une barre absente vaut 0, une courbe s'interrompt (jours futurs du burndown). */
    static Double[] values(Chart chart, Series series) {
        Double[] values = new Double[chart.categories().size()];
        for (int i = 0; i < values.length; i++) {
            Double v = i < series.values().size() ? series.values().get(i) : null;
            values[i] = v == null && chart.type() != ChartType.LINE ? Double.valueOf(0) : v;
        }
        return values;
    }

    static void plot(XDDFChart target, Chart chart, XDDFDataSource<String> categories, List<XDDFNumericalDataSource<Double>> series) {
        target.setTitleText(chart.title());
        target.setTitleOverlay(false);
        XDDFCategoryAxis bottom = target.createCategoryAxis(chart.type() == ChartType.BAR ? AxisPosition.LEFT : AxisPosition.BOTTOM);
        XDDFValueAxis values = target.createValueAxis(chart.type() == ChartType.BAR ? AxisPosition.BOTTOM : AxisPosition.LEFT);
        values.setCrosses(AxisCrosses.AUTO_ZERO);
        XDDFChartData data = target.createData(chart.type() == ChartType.LINE ? ChartTypes.LINE : ChartTypes.BAR, bottom, values);
        for (int i = 0; i < series.size(); i++) {
            Series s = chart.series().get(i);
            XDDFChartData.Series added = data.addSeries(categories, series.get(i));
            added.setTitle(s.name(), null);
            XDDFSolidFillProperties fill = new XDDFSolidFillProperties(XDDFColor.from(HexFormat.of().parseHex(s.color())));
            if (chart.type() == ChartType.LINE) {
                XDDFLineProperties line = new XDDFLineProperties(fill);
                line.setWidth(2.25);
                added.setLineProperties(line);
                ((XDDFLineChartData.Series) added).setMarkerStyle(MarkerStyle.NONE);
                ((XDDFLineChartData.Series) added).setSmooth(false);
            } else {
                added.setFillProperties(fill);
            }
        }
        if (data instanceof XDDFBarChartData bars) {
            bars.setBarDirection(chart.type() == ChartType.BAR ? BarDirection.BAR : BarDirection.COL);
            bars.setBarGrouping(BarGrouping.CLUSTERED);
            bars.setVaryColors(false);
        }
        target.plot(data);
        if (series.size() > 1) {
            target.getOrAddLegend().setPosition(LegendPosition.BOTTOM);
        }
    }
}
