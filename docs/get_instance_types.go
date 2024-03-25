package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"sort"
)

type LinodeType struct {
    ID          string `json:"id"`
    Label       string `json:"label"`
    Disk        int    `json:"disk"`
    Memory      int    `json:"memory"`
}

type LinodeTypesResponse struct {
    Data []LinodeType `json:"data"`
}

func main() {
    resp, err := http.Get("https://api.linode.com/v4/linode/types")
    if err != nil {
        fmt.Println("Erro ao fazer a solicitação:", err)
        return
    }
    defer resp.Body.Close()

    body, err := ioutil.ReadAll(resp.Body)
    if err != nil {
        fmt.Println("Erro ao ler a resposta:", err)
        return
    }

    var linodeTypes LinodeTypesResponse
    err = json.Unmarshal(body, &linodeTypes)
    if err != nil {
        fmt.Println("Erro ao decodificar a resposta JSON:", err)
        return
    }

    typesMap := make(map[string][]LinodeType)
    for _, linodeType := range linodeTypes.Data {
        typesMap[linodeType.ID] = append(typesMap[linodeType.ID], linodeType)
    }

    var ids []string
    for id := range typesMap {
        ids = append(ids, id)
    }
    sort.Strings(ids)

    for _, id := range ids {
        fmt.Println("ID:", id)
        for _, linodeType := range typesMap[id] {
            diskInGB := float64(linodeType.Disk) / 1024
            memoryInGB := float64(linodeType.Memory) / 1024
            fmt.Printf("Label: %s, Disk: %.2f GB, Memory: %.2f GB\n",
                linodeType.Label, diskInGB, memoryInGB)
        }
        fmt.Println()
    }
}
