%%raw(`import './App.css';`)

type addTransaction = {
  typeOfTransaction: string,
  amtOfTransaction: string,
}

type state = {
  transactionList: array<addTransaction>,
  typeOfTransaction: string,
  amtOfTransaction: string,
}

type action =
  AddTransaction | TypeOfTransactionInputChanged(string) | AmtOfTransactionInputChanged(string)

let initialState = {
  transactionList: [],
  typeOfTransaction: "",
  amtOfTransaction: "",
}

let reducer = (state, action) => {
  switch action {
  | AddTransaction => {
      transactionList: state.transactionList->Js.Array2.concat([
        {
          typeOfTransaction: state.typeOfTransaction,
          amtOfTransaction: state.amtOfTransaction,
        },
      ]),
      typeOfTransaction: "",
      amtOfTransaction: "",
    }
  | TypeOfTransactionInputChanged(newValue) => {
      ...state,
      typeOfTransaction: newValue,
    }
  | AmtOfTransactionInputChanged(newValue) => {
      ...state,
      amtOfTransaction: newValue,
    }
  }
}

@react.component
let make = () => {
  let (state, dispatch) = React.useReducer(reducer, initialState)
  let (income, setIncome) = React.useState(_ => 0)
  let (expense, setExpense) = React.useState(_ => 0)

  let handleTypeOfTransaction = e => {
    let newValue = ReactEvent.Form.target(e)["value"]
    newValue->TypeOfTransactionInputChanged->dispatch
  }

  let handleAmtOfTransaction = e => {
    let str = ReactEvent.Form.target(e)["value"]
    Js.String2.replaceByRe(str, %re("/^[ A-Za-z_@./#&*]*$/"), "")
    ->AmtOfTransactionInputChanged
    ->dispatch
  }

  let handleTransactionSubmit = e => {
    dispatch(AddTransaction)
    Js.String.slice(~from=0, ~to_=1, state.amtOfTransaction) == "-"
      ? setExpense(_prev =>
          _prev +
          switch Belt.Int.fromString(Js.String.sliceToEnd(~from=1, state.amtOfTransaction)) {
          | None => -1
          | Some(v) => v
          }
        )
      : setIncome(_prev =>
          _prev +
          switch Belt.Int.fromString(state.amtOfTransaction) {
          | None => -1
          | Some(v) => v
          }
        )
  }

  let list = Belt.Array.map(state.transactionList, transaction => {
    <ul className="list-of-transaction" key={transaction.typeOfTransaction}>
      <li>
        {React.string(transaction.typeOfTransaction)}
        <span> {React.string("$" ++ transaction.amtOfTransaction)} </span>
      </li>
    </ul>
  })

  React.useEffect1(() => {
    Js.log(expense)
    None
  }, [expense])

  <div className="App">
    <h1> {React.string("Expense Tracker")} </h1>
    <div className="expense-tracker-form-container">
      <h4> {React.string("Your Balance: ")} </h4>
      <h1 id="balance"> {React.string("$" ++ Belt.Int.toString(income - expense))} </h1>
      <div className="income-expense-display">
        <div>
          <h4> {React.string("Income: ")} </h4>
          <p className="income-money"> {React.string("$" ++ Belt.Int.toString(income))} </p>
        </div>
        <div>
          <h4> {React.string("Expense: ")} </h4>
          <p className="expense-money"> {React.string("$" ++ Belt.Int.toString(expense))} </p>
        </div>
      </div>
      <h3> {React.string("History")} </h3>
      <div> {React.array(list)} </div>
      <h3> {React.string("Add New Transaction")} </h3>
      <div>
        <div className="transaction-form">
          <label> {React.string("Text")} </label>
          <input
            name="typeOfTransaction"
            value={state.typeOfTransaction}
            type_="text"
            onChange={handleTypeOfTransaction}
          />
        </div>
        <div className="transaction-form">
          <label> {React.string("Amount (negative - expense, positive - income)")} </label>
          <input
            name="amtOfTransaction"
            value={state.amtOfTransaction}
            type_="text"
            onChange={handleAmtOfTransaction}
          />
        </div>
      </div>
      <div className="add-transaction-btn">
        <button onClick={handleTransactionSubmit}> {"Add Transaction"->React.string} </button>
      </div>
    </div>
  </div>
}
