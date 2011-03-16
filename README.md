# API Documentation

## POST /premailer

### Parameters

#### Required

- String `html`
 - HTML content to be cleaned.

#### Optional

- Bool `with_warnings` (default: `0`)
 - When `1`, warnings are returned.

### Response

    {
        "html": "<form style=\"opacity: 0.5; color: red;\"><button>submit</button></form>",
        "warnings": [{
            "level": "RISKY",
            "message": "opacity CSS property",
            "clients": "Outlook 03, Outlook 07, Windows Mail, Entourage 2004, Notes 6, Eudora, New     Yahoo, Old GMail, New GMail, Live Mail, Hotmail"
        }, {
            "level": "SAFE",
            "message": "color CSS property",
            "clients": "Eudora"
        }]
    }