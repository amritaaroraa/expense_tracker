%%raw(`import './index.css';`)

let rootQuery = ReactDOM.querySelector("#root")
let {render, querySelector} = module(ReactDOM)

switch rootQuery {
| None => ()
| Some(root) => render(<App />, root)
}
