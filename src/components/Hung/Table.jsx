function Table(){
    return (
        <div>
            <ul className="nav nav-tabs" role="tablist">
  <li className="nav-item" role="presentation">
    <a className="nav-link active" role="tab" data-bs-toggle="tab" href="#tab-1">NEW USERS</a>
  </li>
  <li className="nav-item" role="presentation">
    <a className="nav-link" role="tab" data-bs-toggle="tab" href="#tab-2">RECENT LOANS</a>
  </li>
  <li className="nav-item" role="presentation">
    <a className="nav-link" role="tab" data-bs-toggle="tab" href="#tab-3">RECENT SUBSCRIPTIONS</a>
  </li>
</ul>
<div className="tab-content">
  <div className="tab-pane active" role="tabpanel" id="tab-1">
    <div className="table-responsive">
      <table className="table">
        <thead>
          <tr>
            <th>#</th>
            <th>Name</th>
            <th>Category</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>1</td>
            <td>Trương Công Đạt</td>
            <td>Student</td>
          </tr>
          <tr>
            <td>2</td>
            <td>Nguyễn Hoàng Phúc</td>
            <td>User</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
  <div className="tab-pane" role="tabpanel" id="tab-2">
    <p>Content for tab 2.</p>
  </div>
  <div className="tab-pane" role="tabpanel" id="tab-3">
    <p>Content for tab 3.</p>
  </div>
</div>
        </div>
    );
}
export default Table;