import LineChart from "./LineChart";
import { Link } from 'react-router-dom';
function RegisterPerDay(pros){
    return (
        <div className="col-lg-7 col-xl-8">
  <div className="card shadow mb-4">
    <div className="card-header d-flex justify-content-between align-items-center">
      <h6 className="text-primary fw-bold m-0">Registers Per Day Overview</h6>
      <div className="dropdown no-arrow">
        
      </div>
    </div>
    <div className="card-body">
      <div className="chart-area">
     <LineChart new_users_per_day={pros.new_users_per_day}></LineChart>
      </div>
    </div>
  </div>
</div>
    );
}
export default RegisterPerDay;