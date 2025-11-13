import { LightningElement, wire, track, api } from 'lwc';
import getOpportunities from '@salesforce/apex/EM_OportunidadProducto.getOpportunities';

export default class clienteOportunidadProducto extends LightningElement {
    @api recordId;
    @track recordCount = 0;
    @track opportunityData;
    @track sortedBy;
    @track sortedDirection;
    @track isLoading = true;

    columns = [
        { label: 'Oportunidad', fieldName: 'Name', sortable: true, initialDirection: 'asc', sortedDirection: 'asc' },
        { label: 'Producto', fieldName: 'ProductName', sortable: true, initialDirection: 'asc', sortedDirection: 'asc' },
        { label: 'Cantidad', fieldName: 'Quantity', sortable: true, initialDirection: 'asc', sortedDirection: 'asc' },
        { label: 'Etapa', fieldName: 'StageName', sortable: true, initialDirection: 'asc', sortedDirection: 'asc' },
        { label: 'Propietario', fieldName: 'OwnerName', sortable: true, initialDirection: 'asc', sortedDirection: 'asc' },
        { label: 'Fecha de Creación', fieldName: 'CreatedDate', sortable: true, initialDirection: 'asc', sortedDirection: 'asc' }
    ];

    @wire(getOpportunities, { accountId: '$recordId' })    
    wiredOpportunities({ error, data }) {
        this.isLoading = true;
        if (data) {
            this.opportunityData = data.map(record => {
                let formattedDate = '';
                if(record.opp.CreatedDate) {
                    formattedDate = new Date(record.opp.CreatedDate).toISOString().split('T')[0] + ' ' + new Date(record.opp.CreatedDate).toISOString().split('T')[1].substring(0,5);
                }
                return {
                    Id: record.opp.Id,
                    Name: record.opp.Name,
                    StageName: record.opp.StageName,
                    CreatedDate: formattedDate,
                    AccountName: record.opp.Account ? record.opp.Account.Name : '',
                    OwnerName: record.opp.Owner ? record.opp.Owner.Name : '',
                    ProductName: record.productName ? record.productName : '',
                    Quantity: record.Quantity
                };
            });
            this.recordCount = this.opportunityData.length;            
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.opportunityData = undefined;
        }
        this.isLoading = false;
    }        

    updateColumnSorting(event) {
        const newSortField = event.detail.fieldName;
    
        if (this.sortedBy === newSortField) {
            this.sortedDirection = this.sortedDirection === 'asc' ? 'desc' : 'asc';
        } else {
            this.sortedDirection = 'asc';
        }
    
        this.sortedBy = newSortField;
        this.sortData(this.sortedBy, this.sortedDirection);
    }    
    
    sortData(fieldName, sortDirection) {
        const data = JSON.parse(JSON.stringify(this.opportunityData));
        const reverse = sortDirection === 'asc' ? 1 : -1;
    
        data.sort((a, b) => {
            a = a[fieldName];
            b = b[fieldName];
    
            // Transformar datos para la comparación
            if (typeof a === 'string') {
                a = a.toLowerCase();
                b = b.toLowerCase();
            } else if (a instanceof Date) {
                a = a.getTime();
                b = b.getTime();
            }
    
            return reverse * ((a > b) - (b > a));
        });
    
        this.opportunityData = data;
    }
}