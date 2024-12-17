import React, { useEffect } from 'react';
import Chart from 'chart.js/auto';
import { useState } from 'react';
const DoughnutChart = (pros) => {
  const [newGroupsPerDay,setInfo]=useState([]);

  useEffect(() => {
   if(pros.new_groups_per_day){
    console.log(pros.new_groups_per_day)
    setInfo(pros.new_groups_per_day)
    const ctx = document.getElementById('myDoughnutChart').getContext('2d');
    const existingChart = Chart.getChart(ctx);

    if (existingChart) {
      existingChart.destroy();
    }

    const data = {
      labels: newGroupsPerDay.map(item => item.date), 
      datasets: [
        {
          backgroundColor: ['#FF5733', '#33FF57', '#3357FF', '#F1C40F', '#9B59B6', '#E74C3C', '#3498DB']
          , 
          borderColor: ['#ffffff', '#ffffff', '#ffffff', '#ffffff', '#ffffff', '#ffffff', '#ffffff'],
          data: newGroupsPerDay.map(item => item.count),}
      ],
    };

    new Chart(ctx, {
      type: 'doughnut',
      data: data,
      options: {
        maintainAspectRatio: false,
        legend: {
          display: false, 
        },
        title: {
          display: false, 
        },
      },
    });
   }
  }, [pros.new_groups_per_day]);

  return <canvas id="myDoughnutChart" />;
};

export default DoughnutChart;
