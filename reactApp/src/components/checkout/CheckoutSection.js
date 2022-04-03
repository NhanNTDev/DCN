import { useEffect, useState } from "react";
import { useDispatch, useSelector } from "react-redux";
import { Link, useNavigate } from "react-router-dom";
import orderApi from "../../apis/orderApi";
import cartApi from "../../apis/cartApi";
import { Spin, Radio, Space, message, notification } from "antd";
import { LoadingOutlined } from "@ant-design/icons";
import { setCart } from "../../state_manager_redux/cart/cartSlice";
import addressApi from "../../apis/addressApis";
import {
  getCartTotal,
  getOrderCouter,
} from "../../state_manager_redux/cart/cartSelector";
import CreateAddressForm from "../address/CreateAddressFrom";

const CheckoutSection = () => {
  const order = useSelector((state) => state.order);
  const cart = useSelector((state) => state.cart);
  const user = useSelector((state) => state.user);
  const [loading, setLoading] = useState(false);
  const antIcon = <LoadingOutlined style={{ fontSize: 32 }} spin />;
  const [addresses, setAddresses] = useState([]);
  const orderCount = useSelector(getOrderCouter);
  const [selectedAddress, setSelectedAddress] = useState();
  const [currentStep, setCurrentStep] = useState(1);
  const [changePlag, setChangePlag] = useState(true);
  const [shipCost, setShipCost] = useState(30000);
  const navigate = useNavigate();
  const dispatch = useDispatch();
  const cartTotal = useSelector(getCartTotal);

  useEffect(() => {
    if (orderCount === 0) {
      navigate("/cart");
    }
  }, []);
  useEffect(() => {
    const fetchAddess = async () => {
      const result = await addressApi
        .getAll(user.id)
        .catch((err) => console.log(err));
      if (result !== null) {
        setAddresses(result);
        setSelectedAddress(result[0]);
      }
    };
    fetchAddess();
  }, [changePlag]);

  const afterCreateAddressCallback = () => {
    setChangePlag(!changePlag);
  };

  const renderCampaign = (props) => {
    return props.harvestInCampaigns.map((harvest) =>
      renderHarvestCampaign({ ...harvest })
    );
  };

  const onChangeRadio = (e) => {
    setSelectedAddress(e.target.value);
  };

  const renderHarvestCampaign = (props) => {
    if (props.checked) {
      return (
        <div className="card-body pt-0 pr-0 pl-0 pb-0">
          <div className="cart-list-product">
            <a className="float-right remove-cart" href="#">
              <i className="mdi mdi-close"></i>
            </a>
            <img className="img-fluid" src={props.image} alt="" />
            <h5>
              <a href="#">{props.productName}</a>
            </h5>
            <h6>
              <strong>Số lượng:</strong> {props.quantity} {props.unit}
            </h6>
            <p className="offer-price mb-0">
              {props.price.toLocaleString()}{" "}
              <i className="mdi mdi-tag-outline"></i>{" "}
            </p>
          </div>
        </div>
      );
    }
  };

  const renderAddressRadioItem = (props) => {
    return (
      <Radio key={props.id} value={props}>
        <>
          <strong>{props.name}</strong> - <strong>{props.phone}</strong> <br />{" "}
          {props.address1}
        </>
      </Radio>
    );
  };

  const handleCheckout = () => {
    setLoading(true);
    const checkout = async () => {
      const data = {
        phone: selectedAddress.phone,
        email: user.email,
        address: selectedAddress.address1,
        customerId: user.id,
        paymentTypeId: 1,
        campaignId: cart.campaignId,
        farmOrders: order,
      };
      console.log(data);
      const result = await orderApi.post(data).catch((err) => {
        notification.error({
          duration: 3,
          message: err.response.data.error.message,
          style:{fontSize: 16},
        });
        setCurrentStep(1);
      });
      if (result === "Order Successfully!") {
        setCurrentStep(3);
      }
    };

    const fetchCartItems = async () => {
      const cartItemsResponse = await cartApi.getAll(user.id);
      const action = setCart(cartItemsResponse);
      dispatch(action);

      setLoading(false);
    };
    checkout();
    fetchCartItems();
  };

  return (
    <>
      <section className="checkout-page section-padding">
        <div className="container">
          <div className="d-flex justify-content-center">
            {loading ? (
              <>
                <Spin indicator={antIcon} /> <br /> <br />{" "}
              </>
            ) : null}
          </div>
          <div className="row">
            <div className="col-md-8">
              <div className="checkout-step">
                <div className="accordion" id="accordionExample">
                  <div className="card checkout-step-one">
                    <div className="card-header" id="headingOne">
                      <h5 className="mb-0">
                        <button
                          className={
                            currentStep === 1
                              ? "btn btn-link"
                              : "btn btn-link collapsed"
                          }
                          type="button"
                          aria-expanded="true"
                          aria-controls="collapseOne"
                        >
                          <span className="number">1</span>Xác Nhận Địa Chỉ Giao
                          Hàng
                        </button>
                      </h5>
                    </div>
                    <div
                      id="collapseOne"
                      className={
                        currentStep === 1 ? "collapse show" : "collapse"
                      }
                      aria-labelledby="headingOne"
                      data-parent="#accordionExample"
                    >
                      <div className="card-body">
                        <div className="row">
                          <Radio.Group
                            onChange={(e) => {
                              onChangeRadio(e);
                            }}
                            value={selectedAddress}
                          >
                            <Space direction="vertical">
                              {addresses &&
                                addresses.map((address) =>
                                  renderAddressRadioItem(address)
                                )}
                            </Space>
                          </Radio.Group>
                        </div>
                        <br />
                        <CreateAddressForm
                          currentPage="checkout"
                          callback={afterCreateAddressCallback}
                        />
                        <br />

                        <button
                          type="button"
                          aria-expanded="false"
                          aria-controls="collapseTwo"
                          className="btn btn-secondary mb-2 btn-lg"
                          onClick={() => setCurrentStep(2)}
                        >
                          Tiếp
                        </button>
                        <button
                          type="button"
                          onClick={() => navigate("/cart")}
                          style={{ marginLeft: 30 }}
                          className="btn btn-secondary mb-2 btn-lg"
                        >
                          Trở về
                        </button>
                      </div>
                    </div>
                  </div>
                  <div className="card checkout-step-two">
                    <div className="card-header" id="headingTw0">
                      <h5 className="mb-0">
                        <button
                          className={
                            currentStep === 2
                              ? "btn btn-link"
                              : "btn btn-link collapsed"
                          }
                          type="button"
                          aria-expanded="true"
                          aria-controls="collapseTwo"
                        >
                          <span className="number">2</span>Xác nhận thông tin
                          đơn hàng
                        </button>
                      </h5>
                    </div>
                    <div
                      id="collapseTow"
                      className={
                        currentStep === 2 ? "collapse show" : "collapse"
                      }
                      aria-labelledby="headingTow"
                      data-parent="#accordionExample"
                    >
                      <div className="card-body">
                        {selectedAddress && (
                          <div>
                            <h4>I. Thông tin giao hàng</h4>
                            <h5>
                              <strong className="title">
                                Tên người nhận:{" "}
                              </strong>{" "}
                              {selectedAddress.name}
                            </h5>
                            <h5>
                              <strong className="title">Số điện thoại: </strong>{" "}
                              {selectedAddress.phone}
                            </h5>
                            <h5>
                              <strong className="title">Địa chỉ: </strong>{" "}
                              {selectedAddress.address1}
                            </h5>
                            <h4>II. Thông tin đơn hàng</h4>
                            <h5>
                              <strong className="title">Số lượng hàng: </strong>{" "}
                              {orderCount} sản phẩm
                            </h5>
                            <h5>
                              <strong className="title">Phí ship: </strong>
                              {shipCost.toLocaleString() + " VNĐ"}
                            </h5>
                            <h5>
                              <strong className="title">Tiền hàng: </strong>{" "}
                              {cartTotal.toLocaleString() + " VNĐ"}
                            </h5>
                            <h5>
                              <strong className="title">
                                Cần thanh toán:{" "}
                              </strong>
                              {(shipCost + cartTotal).toLocaleString() + " VNĐ"}{" "}
                            </h5>
                          </div>
                        )}
                        <button
                          type="button"
                          aria-expanded="false"
                          aria-controls="collapseTwo"
                          className="btn btn-secondary mb-2 btn-lg"
                          onClick={handleCheckout}
                        >
                          Tiếp
                        </button>
                        <button
                          type="button"
                          onClick={() => {
                            setCurrentStep(1);
                          }}
                          style={{ marginLeft: 30 }}
                          className="btn btn-secondary mb-2 btn-lg"
                        >
                          Trở về
                        </button>
                      </div>
                    </div>
                  </div>

                  <div className="card">
                    <div className="card-header" id="headingThree">
                      <h5 className="mb-0">
                        <button
                          className={
                            currentStep === 3
                              ? "btn btn-link"
                              : "btn btn-link collapsed"
                          }
                          type="button"
                          aria-expanded="false"
                          aria-controls="collapseThree"
                        >
                          <span className="number">3</span> Hoàn Tất Đặt Hàng
                        </button>
                      </h5>
                    </div>
                    <div
                      id="collapseThree"
                      className={
                        currentStep === 3 ? "collapse show" : "collapse"
                      }
                      aria-labelledby="headingThree"
                      data-parent="#accordionExample"
                    >
                      <div className="card-body">
                        <div className="text-center">
                          <div className="col-lg-10 col-md-10 mx-auto order-done">
                            <i className="mdi mdi-check-circle-outline text-secondary"></i>

                            <h4 className="text-success">
                              Chúc mừng! Đơn hàng của bạn đã thành công.
                            </h4>
                          </div>
                          <div className="text-center">
                            <Link to="/">
                              <button
                                type="submit"
                                className="btn btn-secondary mb-2 btn-lg"
                              >
                                Về Trang chủ
                              </button>
                            </Link>
                          </div>{" "}
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <div className="col-md-4">
              <div className="card">
                <h5 className="card-header">
                  Giỏ Hàng
                  <span className="text-secondary float-right">
                    {orderCount} sản phẩm
                  </span>
                </h5>

                {cart && cart.farms.map((farm) => renderCampaign({ ...farm }))}
              </div>
            </div>
          </div>
        </div>
      </section>
    </>
  );
};

export default CheckoutSection;
