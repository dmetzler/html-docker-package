import React, { Component } from 'react';
import ReactJson from 'react-json-view';
import {
    Navbar,
    NavbarBrand,
    Container,
    Row,
    Col,
    Jumbotron,
    Button
} from 'reactstrap';

class App extends Component {
    constructor(props) {
        super(props);
        this.app = window._env_.API_URL;
        this.toggle = this.toggle.bind(this);
        this.state = {
            isOpen: false
        };

    }

    getState() {

      fetch(this.app, {
        method: "GET",
        dataType: "JSON",
        headers: {
          "Content-Type": "application/json; charset=utf-8",
        }
      })
      .then(response => response.json())
      .then(data => {
        console.log(data)
        this.setState({nuxeo: data});
      })
      .catch((error) => {
        console.log(error, "Get Nuxeo Status")
      })

    }

    toggle() {
        this.setState({
            isOpen: !this.state.isOpen
        });
    }
    render() {
        return (
            <div>
                <Navbar color="inverse" light expand="md">
                    <NavbarBrand href="/">Nuxeo Status</NavbarBrand>

                </Navbar>
                <Jumbotron>
                    <Container>
                        <Row>
                            <Col>
                                <h1>Does My Nuxeo Application run?</h1>
                                <p>
                                    <Button
                                        tag="a"
                                        color="success"
                                        size="large"
                                        onClick={() => this.getState()}
                                    >
                                        {this.app}
                                    </Button>
                                </p>
                                <ReactJson src={this.state.nuxeo} />
                            </Col>
                        </Row>
                    </Container>
                </Jumbotron>
            </div>
        );
    }
}

export default App;