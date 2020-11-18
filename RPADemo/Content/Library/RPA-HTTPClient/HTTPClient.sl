namespace: RPA-HTTPClient
flow:
  name: HTTPClient
  inputs:
    - excel_file_name: "D:\\\\Demo\\\\RPA\\\\LoansCalculation.xlsx"
    - userID_header: userID
    - pass_header: pass
    - ammount_header: ammount
    - rate_header: rate
    - months_header: months
  workflow:
    - get_cell:
        do:
          io.cloudslang.base.excel.get_cell:
            - excel_file_name: '${excel_file_name}'
            - worksheet_name: LoansCalculation
            - has_header: 'yes'
            - first_row_index: '0'
            - row_index: '0:5'
            - column_index: '0:5'
            - row_delimiter: '|'
            - column_delimiter: ','
            - userID_header: '${userID_header}'
            - pass_header: '${pass_header}'
            - ammount_header: '${ammount_header}'
            - rate_header: '${rate_header}'
            - months_header: '${months_header}'
        publish:
          - data: '${return_result}'
          - header
          - userID_index: '${str(header.split(",").index(userID_header))}'
          - pass_index: '${str(header.split(",").index(pass_header))}'
          - ammount_index: '${str(header.split(",").index(ammount_header))}'
          - rate_index: '${str(header.split(",").index(rate_header))}'
          - months_index: '${str(header.split(",").index(months_header))}'
        navigate:
          - SUCCESS: http_client_post
          - FAILURE: on_failure
    - http_client_post:
        loop:
          for: 'row in data.split("|")'
          do:
            io.cloudslang.base.http.http_client_post:
              - url: 'http://192.168.0.10:9680/vhi-ws/model/BankDemo?wsdl'
              - body: "${'<Envelope xmlns=\"http://schemas.xmlsoap.org/soap/envelope/\">    <Body>        <calcCostLoan xmlns=\"urn:xmlns:attachmate:vhi-ws:BankDemo\">            <calcCostLoanFilters>                <Password>'+row.split(\",\")[int(pass_index)]+'</Password>                <UserId>'+row.split(\",\")[int(userID_index)]+'</UserId>                <AmtToBorrow>'+row.split(\",\")[int(ammount_index)][:-2]+'</AmtToBorrow>                <IntRate>'+row.split(\",\")[int(rate_index)]+'</IntRate>                <NumOfMonths>'+row.split(\",\")[int(months_index)][:-2]+'</NumOfMonths>            </calcCostLoanFilters>        </calcCostLoan>    </Body></Envelope>'}"
          break:
            - FAILURE
          publish:
            - xml_result: '${return_result}'
        navigate:
          - SUCCESS: xpath_query
          - FAILURE: on_failure
    - xpath_query:
        do:
          io.cloudslang.base.xml.xpath_query:
            - xml_document: '${xml_result}'
            - xpath_query: .//ResultMonthPmt
        publish:
          - selected_value
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  outputs:
    - flow_output_0
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      http_client_post:
        x: 302
        'y': 96
      get_cell:
        x: 102
        'y': 87
      xpath_query:
        x: 479
        'y': 101
        navigate:
          746f71b9-d5bb-6488-cda0-e6cef63b7373:
            targetId: a788c5e9-f475-194f-e3e1-981ed59bf642
            port: SUCCESS
    results:
      SUCCESS:
        a788c5e9-f475-194f-e3e1-981ed59bf642:
          x: 660
          'y': 97
