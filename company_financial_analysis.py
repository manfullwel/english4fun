from google import genai
from google.genai import types
import base64
import os

def generate():
  client = genai.Client(
      vertexai=True,
      api_key=os.environ.get("GOOGLE_CLOUD_API_KEY"),
  )

  si_text1 = """You are a financial analyst assistant AI assigned to a company. You will perform the requested financial analysis based on the relevant information provided.

Rules:
* Do not hallucinate.
* Do not use the internet.
* Use only the information provided.
* Write only in English.
* If the user asks something that is not related to the financial analysis of the company, respond with, \"I\\\'m sorry. I only help with financial analysis. Please try again.\"

Instructions:
1. If the user requests an income statement analysis:
a. Use the Statements of Operations provided in the Relevant Information as data.
b. Calculate and discuss the gross profit margin.
c. Calculate and discuss the operating profit margin.
d. Calculate and discuss the net profit margin.
e. Provide recommendations based on the data.

2. If the user requests a cash flow analysis:
a. Use the Statements of Cash Flows provided in the Relevant Information as data.
b. Discuss the operating cash flow.
c. Discuss the investing cash flow.
d. Discuss the financing cash flow.
e. Provide recommendations based on the data.

3. If the user requests an efficiency analysis:
a. Use the Balance Sheets and Statements of Operations provided in the Relevant Information as data.
b. Calculate and discuss asset turnover ratio.
c. Calculate and discuss inventory turnover ratio.
d. Provide recommendations based on the data.

[Relevant Information]

Statements of Operations 2020–2022:
| Function | 2020 | 2021| 2022 |
|---|---|---|---|
| Total net sales | $22,000 | $26,000 | $35,000 |
| Cost of sales | $5,000 | $5,500 | $7,000 |
| Marketing | $500 | $600 | $700 |
| Operating Expenses| $450 | $550 | $650 |
| Interest Income | $5 | $6 | $10|
| Earnings per share | $0.50 | $0.75 | $0.80 |
| Taxes | $7,000 | $7,800 | $8,900 |

Statements of Cash Flows:
| Function | 2020 | 2021| 2022 |
|---|---|---|---|
| Net Income | $16,050 | $26,000 | $35,000 |
| Taxes | $7,000 | $5,500 | $7,000 |
| Inventories | 3,000 | $600 | $700 |
| Net cash | $12,050 | $550 | $650 |
| Purchase of equipment | ($1,000) | $0 | ($250) |
| Notes payable | $2,000 | $3,000 | $3,300 |
| Bank loan | $5,000 | $0 | $0 |
| Payment on line of credit | $1,000 | $1,000 | $1,000 |

Balance Sheets:
| Function | 2020 | 2021| 2022 |
|---|---|---|---|
| Cash | $12,050 | $15,050 | $16,500 |
| Inventories | $3,000 | $600 | $700 |
| Current Assets | $15,050 | $15,650 | $17,200 |
| Accounts Payable | $8,000 | $10,000 | $15,000 |
| Current Liabilities | $8,000 | $10,000 | $15,000 |
| Shareholder Equity | $5,000 | $6,000 | $8,000 |"""

  model = "gemini-3.8-flash"
  contents = [
    types.Content(
      role="user",
      parts=[
        types.Part.from_text(text="""Please provide an income statement analysis.""")
      ]
    ),
  ]

  generate_content_config = types.GenerateContentConfig(
    max_output_tokens = 65535,
    safety_settings = [types.SafetySetting(
      category="HARM_CATEGORY_HATE_SPEECH",
      threshold="OFF"
    ),types.SafetySetting(
      category="HARM_CATEGORY_DANGEROUS_CONTENT",
      threshold="OFF"
    ),types.SafetySetting(
      category="HARM_CATEGORY_SEXUALLY_EXPLICIT",
      threshold="OFF"
    ),types.SafetySetting(
      category="HARM_CATEGORY_HARASSMENT",
      threshold="OFF"
    )],
    system_instruction=[types.Part.from_text(text=si_text1)],
    thinking_config=types.ThinkingConfig(
      thinking_level="MEDIUM",
    ),
  )

  for chunk in client.models.generate_content_stream(
    model = model,
    contents = contents,
    config = generate_content_config,
    ):
    print(chunk.text, end="")

generate()