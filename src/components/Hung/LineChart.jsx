import { useEffect } from 'react';
import Chart from 'chart.js/auto';
import { useState } from 'react';
const LineChart = (props) => {
  useEffect(() => {

    if(props.new_users_per_day){
      const ctx = document.getElementById('myLineChart').getContext('2d');
    const existingChart = Chart.getChart(ctx);

    if (existingChart) {
      existingChart.destroy(); 
    }

    
    const newUsersPerDay = props.new_users_per_day;

   
    const labels = newUsersPerDay.map((item) => item.date);
    const data = newUsersPerDay.map((item) => item.count); 

    const chartData = {
      type: 'line',
      data: {
        labels: labels,
        datasets: [
          {
            label: 'New Users',
            fill: false,
            data: data, 
            backgroundColor: 'rgba(78, 115, 223, 0.05)',
            borderColor: 'rgba(78, 115, 223, 1)',
          },
        ],
      },
      options: {
        maintainAspectRatio: false,
        legend: {
          display: false,
          labels: {
            fontStyle: 'normal',
          },
        },
        title: {
          fontStyle: 'normal',
        },
        scales: {
          xAxes: [
            {
              gridLines: {
                color: 'rgb(234, 236, 244)',
                zeroLineColor: 'rgb(234, 236, 244)',
                drawBorder: false,
                drawTicks: false,
                borderDash: [2],
                zeroLineBorderDash: [2],
                drawOnChartArea: false,
              },
              ticks: {
                fontColor: '#858796',
                fontStyle: 'normal',
                padding: 20,
              },
            },
          ],
          yAxes: [
            {
              gridLines: {
                color: 'rgb(234, 236, 244)',
                zeroLineColor: 'rgb(234, 236, 244)',
                drawBorder: false,
                drawTicks: false,
                borderDash: [2],
                zeroLineBorderDash: [2],
              },
              ticks: {
                fontColor: '#858796',
                fontStyle: 'normal',
                padding: 20,
              },
            },
          ],
        },
      },
    };

   
    new Chart(ctx, chartData);
    }
  }, [props.new_users_per_day]); 
  return <canvas id="myLineChart" />;
};

export default LineChart;
