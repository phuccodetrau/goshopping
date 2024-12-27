import DoughnutChart from "./DoughnutChart";
function NewGroupPerDay(pros){
    return (
        <div className="col-lg-5 col-xl-4">
  <div className="card shadow mb-4">
    <div className="card-header d-flex justify-content-between align-items-center">
      <h6 className="text-primary fw-bold m-0">New Groups Per Day Overview</h6>
      
    </div>
    <div className="card-body">
      <div className="chart-area">
      <DoughnutChart new_groups_per_day={pros.new_groups_per_day}></DoughnutChart>
      </div>
     
    </div>
  </div>
</div>
    );
}
export default NewGroupPerDay;