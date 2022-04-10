import { notification, Table, Result, Button } from "antd";
import { Link, useSearchParams } from "react-router-dom";
import { useEffect, useState } from "react";
import orderApi from "../../apis/orderApi";
const OrderDetailsTable = () => {
  const [page, setPage] = useState(1);
  const [total, setTotal] = useState(1);
  const [products, setProducts] = useState([]);
  const [order, setOrder] = useState();
  const [loading, setLoading] = useState(true);
  const [reload, setReload] = useState(true);
  const [loadErr, setLoadErr] = useState(false);
  const [searchParams] = useSearchParams();
  const orderId = searchParams.get("id");
  useEffect(() => {
    setLoadErr(false);
    const getOrderDetails = async () => {
      await orderApi
        .getOrderDetails(orderId)
        .then((result) => {
          if (result) {
            setOrder(result);
            let listProduct = [];
            let index = 1;
            setTotal(Object.entries(result.productHarvestOrders).length);
            result.productHarvestOrders.map((product) => {
              listProduct.push({ index: index++, ...product });
            });
            setProducts(listProduct);
          }
        })
        .catch((err) => {
          if (err.message === "Network Error") {
            notification.error({
              duration: 3,
              message: "Mất kết nối mạng!",
              style: { fontSize: 16 },
            });
          } else {
            notification.error({
              duration: 3,
              message: "Có lỗi xảy ra trong quá trình xử lý!",
              style: { fontSize: 16 },
            });
          }
          setLoadErr(true);
        });

      setLoading(false);
    };
    getOrderDetails();
  }, [page, reload]);

  const columns = [
    {
      title: "STT",
      dataIndex: "index",
      key: "index",
    },
    {
      title: "Tên sản phẩm",
      dataIndex: "productName",
      key: "productName",
    },

    {
      title: "Số lượng",
      dataIndex: "quantity",
      key: "quantity",
    },
    {
      title: "Đơn vị",
      dataIndex: "unit",
      key: "unit",
    },
    {
      title: "Giá",
      dataIndex: "price",
      key: "prive",
      render: (text, record) => (
        <div>{record.price.toLocaleString() + " VNĐ"}</div>
      ),
    },

    {
      title: "Tổng tiền",
      dataIndex: "total",
      key: "total",
      render: (text, record) => (
        <div>{record.total.toLocaleString() + " VNĐ"}</div>
      ),
    },
  ];
  return (
    <>
      {loadErr ? (
        <Result
          status="error"
          title="Đã có lỗi xảy ra!"
          subTitle="Rất tiếc đã có lỗi xảy ra trong quá trình tải dữ liệu, quý khách vui lòng kiểm tra lại kết nối mạng và thử lại."
          extra={[
            <Button
              type="primary"
              key="console"
              onClick={() => {
                setReload(!reload);
              }}
            >
              Tải lại
            </Button>,
          ]}
        ></Result>
      ) : (
        <div class="card card-body account-right">
          <div class="widget">
            <div class="section-header">
              <Link to="/orderList" className="btn btn-secondary">
                Trở về
              </Link>
              <br />
              <br />
              <h4 class="heading-design-h4">
                Chi tiết đơn hàng {order && order.code}
              </h4>
            </div>
            <br />
            <div class="order-list-tabel-main table-responsive">
              <h5 class="heading-design-h5">
                <strong>Tên chiến dịch: </strong> {order && order.campaignName}
              </h5>
              <h5 class="heading-design-h5">
                <strong>Địa chỉ nhận hàng: </strong>
                {order && order.address}
              </h5>
              <h5 class="heading-design-h5">
                <strong>Số điện thoại nhận hàng: </strong>
                {order && order.phone}
              </h5>
              <h5 class="heading-design-h5">
                <strong>Ngày tạo: </strong>
                {order && order.dateTimeParse}
              </h5>
              <h5 class="heading-design-h5">
                <strong>Trạng thái: </strong>
                {order && order.status}
              </h5>
              <h5 class="heading-design-h5">
                <strong>Tổng tiền: </strong>
                {order && order.total.toLocaleString() + " VNĐ"}
              </h5>
              <h5 class="heading-design-h5">
                <strong>Danh sách sản phẩm: </strong>
              </h5>
              <Table
                columns={columns}
                dataSource={products}
                pagination={{
                  position: ["bottomCenter"],
                  pageSize: 10,
                  total: total,
                  onChange: (page) => {
                    setPage(page);
                  },
                }}
                loading={loading}
                style={{ margin: 50 }}
              />
            </div>
          </div>
        </div>
      )}
    </>
  );
};

export default OrderDetailsTable;
